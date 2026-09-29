#!/bin/bash
buildApp=${1:-"UV"}
clear
rm -rf *.lock dist/ **/*.egg-info/ *.venv/

export JF_NAME="psazuse" JFROG_CLI_LOG_LEVEL="DEBUG" TIMESTAMP="$(date '+%Y.%m.%d+%H%M')"
export RT_REPO_VIRTUAL="py-uv-virtual" # py-uv-local 

export JFROG_CLI_BUILD_NAME="py-uv-app" JFROG_CLI_BUILD_NUMBER="uv-${TIMESTAMP}"
export REPO_REGISTRY="https://${JF_NAME}.jfrog.io/artifactory/api/pypi/${RT_REPO_VIRTUAL}" # /simple

jf config use ${JF_NAME}
export JFROG_RUN_NATIVE=true
export JFROG_CLI_GHOST_FROG=true

printf "\n*** Using traditional commands \n"
if [ -z "${PSAZUSE_JF_ACCESS_TOKEN:-}" ]; then
    printf "PSAZUSE_JF_ACCESS_TOKEN is not set; native npm cannot authenticate to Artifactory.\n"
    exit 1
fi

export UV_PUBLISH_URL=${REPO_REGISTRY}
export UV_PUBLISH_USERNAME=${PSAZUSE_JF_USERNAME}
export UV_PUBLISH_PASSWORD=${PSAZUSE_JF_ACCESS_TOKEN}

echo "USERNAME: ${UV_PUBLISH_USERNAME}"
echo "TOKEN: ${UV_PUBLISH_PASSWORD}"


uv auth login ${REPO_REGISTRY} --username ${UV_PUBLISH_USERNAME} --password ${UV_PUBLISH_PASSWORD}

# jf package-alias install --packages=uv

uv sync
uv build 
uv publish dist/* --index py-uv-virtual

# uv run uvicorn src.main:app --reload


jf rt bp "${JFROG_CLI_BUILD_NAME}" "${JFROG_CLI_BUILD_NUMBER}" --collect-env=true --detailed-summary=true



printf "\n*** Build name: ${JFROG_CLI_BUILD_NAME}  build number: ${JFROG_CLI_BUILD_NUMBER} \n"
jf -v

