import os
import hvac

def get_secret_or_env(path: str, key: str, default: str = "") -> str:
    # Try Vault first, then env var fallback
    url = os.getenv("VAULT_ADDR", "http://vault:8200")
    token = os.getenv("VAULT_TOKEN", "root")
    mount = os.getenv("VAULT_MOUNT", "secret")
    client = hvac.Client(url=url, token=token)
    try:
        if client.is_authenticated():
            resp = client.secrets.kv.v2.read_secret_version(path=path, mount_point=mount)
            return resp["data"]["data"].get(key, default)
    except Exception:
        pass
    return os.getenv(key.upper(), default)
