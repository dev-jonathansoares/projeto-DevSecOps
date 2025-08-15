from fastapi.testclient import TestClient
from app.main import app

def test_root():
    c = TestClient(app)
    r = c.get("/")
    assert r.status_code == 200
    assert "message" in r.json()
