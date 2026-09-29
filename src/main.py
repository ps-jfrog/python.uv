from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI()

# Point to project root from src/ (one level up from src/main.py)
BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATE_PATH = BASE_DIR / "templates" / "index.html"


@app.get("/", response_class=HTMLResponse)
async def read_index():
    """Reads HTML text from ./templates/index.html and returns it."""
    html_content = TEMPLATE_PATH.read_text(encoding="utf-8")
    return HTMLResponse(content=html_content, status_code=200)


@app.get("/inline", response_class=HTMLResponse)
async def read_inline():
    """Returns raw inline HTML text."""
    raw_html = """
    <!DOCTYPE html>
    <html>
        <head><title>Inline HTML</title></head>
        <body style="font-family: sans-serif; padding: 2rem;">
            <h2>Inline HTML Route</h2>
            <p>Served directly from string text inside <code>./src/main.py</code>.</p>
        </body>
    </html>
    """
    return HTMLResponse(content=raw_html, status_code=200)