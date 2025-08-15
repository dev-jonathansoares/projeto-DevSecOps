from fastapi import FastAPI
import os, httpx
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="DevSecOps Demo App")
Instrumentator().instrument(app).expose(app, endpoint="/metrics")

def get_message():
    vault_addr = os.getenv("VAULT_ADDR", "http://vault:8200")
    vault_token = os.getenv("VAULT_TOKEN", "")
    message = os.getenv("MESSAGE", "").strip()
    if vault_token:
        try:
            r = httpx.get(f"{vault_addr}/v1/secret/data/app", headers={"X-Vault-Token": vault_token}, timeout=5.0)
            if r.status_code == 200:
                return r.json()["data"]["data"].get("message", "Hello from Vault!")
        except Exception:
            pass
    return message or "Hello from Vault!"

@app.get("/")
def root(): return {"message": get_message()}

@app.get("/healthz")
def healthz(): return {"status": "ok"}
