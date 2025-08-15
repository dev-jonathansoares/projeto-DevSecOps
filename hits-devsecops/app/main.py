from fastapi import FastAPI
from pydantic import BaseModel
import os
from datetime import datetime, timezone

APP_PORT = int(os.getenv("PORT", "5001"))
APP_ENV = os.getenv("APP_ENV", "local")
GREETING = os.getenv("GREETING", "Hello from HITS")
VERSION = os.getenv("VERSION", "0.1.0")

app = FastAPI(title="HITS DevSecOps Demo", version=VERSION)

class EchoBody(BaseModel):
    message: str

@app.get("/")
def root():
    return {
        "message": f"{GREETING}! This is a tiny FastAPI app by HITS.",
        "env": APP_ENV,
        "version": VERSION,
        "docs": "/docs",
        "endpoints": ["/health", "/version", "/time", "/env", "/echo"]
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/version")
def version():
    return {"version": VERSION}

@app.get("/env")
def env():
    return {"env": APP_ENV, "greeting": GREETING}

@app.get("/time")
def time_now():
    return {"now_utc": datetime.now(timezone.utc).isoformat()}

@app.post("/echo")
def echo(body: EchoBody):
    return {"you_said": body.message}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=APP_PORT, reload=True)
