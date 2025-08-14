from fastapi import FastAPI
from fastapi.responses import JSONResponse, PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from vault_client import get_secret_or_env
import os

app = FastAPI(title="Secure PyApp", version="1.0.0")

REQUESTS = Counter("secure_pyapp_requests_total", "Total HTTP requests", ["endpoint"])

@app.get("/health")
def health():
    REQUESTS.labels(endpoint="/health").inc()
    return {"status": "ok"}

@app.get("/secret")
def read_secret():
    REQUESTS.labels(endpoint="/secret").inc()
    api_key = get_secret_or_env("app/config", "api_key", "not-set")
    return {"api_key": api_key}

@app.get("/")
def root():
    REQUESTS.labels(endpoint="/").inc()
    message = os.getenv("APP_MESSAGE", "Hello, DevSecOps!")
    return {"message": message}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return PlainTextResponse(data.decode("utf-8"), media_type=CONTENT_TYPE_LATEST)
