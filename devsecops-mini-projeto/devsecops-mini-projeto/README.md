# DevSecOps Mini Project — Secure PyApp (Python + Docker + OpenShift)

Um mini-projeto **100% focado em DevSecOps** para você demonstrar habilidades práticas:
- CI/CD com **Jenkins** (lint, testes, SAST, SCA, DAST, build e push)
- Segurança integrada ao SDLC (**Bandit**, **Trivy**, **OWASP ZAP**, **SonarQube**)
- Observabilidade com **Prometheus** e **Grafana**
- Segredos com **HashiCorp Vault** (dev mode)
- Deploy local com **Docker Compose** e em **OpenShift**
- Código em **Python (FastAPI)** com métricas Prometheus
- Documentação passo a passo

> Portas utilizadas (evita conflitos com a 8080): App 5001, Jenkins 8090, Sonar 9000, Prometheus 9090, Grafana 3000, Vault 8200.

---

## 1) Requisitos
- Docker e Docker Compose
- (Opcional) `oc` CLI para OpenShift e acesso a um cluster OpenShift
- (Opcional) `kubectl` para Kubernetes

---

## 2) Subindo o ambiente com Docker Compose

### 2.1 Perfis disponíveis
- `core`: somente o app
- `ci`: Jenkins
- `sec`: SonarQube e Vault
- `obs`: Prometheus e Grafana

### 2.2 Subir tudo
```bash
docker compose --profile core --profile ci --profile sec --profile obs up -d --build
```

Acesse:
- App: http://localhost:5001
- Health: http://localhost:5001/health
- Métricas: http://localhost:5001/metrics
- Jenkins: http://localhost:8090
- SonarQube: http://localhost:9000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- Vault: http://localhost:8200  (token dev: `root`)

### 2.3 Inicializar o Vault (dev)
```bash
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
./vault/init.sh
# /secret/app/config api_key=super-secret-demo-key
```

Teste o endpoint:
```bash
curl http://localhost:5001/secret
```

---

## 3) Segurança no SDLC

### 3.1 Lint & Testes
```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r app/requirements.txt
flake8 app
pytest -q app/tests
```

### 3.2 SAST (Bandit)
```bash
bandit -c app/bandit.yaml -r app -f txt -o bandit.txt || true
```

### 3.3 SCA (Trivy)
```bash
docker build -t secure-pyapp:local app
./security/trivy_scan.sh secure-pyapp:local
```

### 3.4 SonarQube (qualidade de código)
- Configure um token no Sonar e exporte as variáveis no Jenkins ou localmente.
- Arquivo: `app/sonar-project.properties`

### 3.5 DAST (OWASP ZAP Baseline)
Com o app rodando:
```bash
./security/zap_baseline.sh http://localhost:5001
# gera zap_report.html
```

---

## 4) Jenkins CI/CD

- Use a imagem `jenkins/jenkins:lts` já orquestrada no Compose (porta 8090).
- Crie credenciais:
  - `docker-registry` (usuário/senha ou token)
  - `sonar-host-url` (string com URL, ex: http://sonar:9000)
  - `sonar-token` (token do Sonar)
- Configure a integração SonarQube no Jenkins (Manage Jenkins → Configure System → SonarQube).
- Pipeline: `Jenkinsfile` com estágios: checkout → lint/test → **Bandit** → build Docker → **Trivy** → **SonarQube** → **ZAP** → push (opcional) → deploy OpenShift (manual opcional).

Execute o pipeline apontando para este repositório.

---

## 5) Observabilidade

Prometheus já coleta de `app:5001/metrics`. O Grafana é provisionado com datasource Prometheus e um dashboard simples.

- Acesse Grafana: http://localhost:3000
- Explore a métrica `secure_pyapp_requests_total`

---

## 6) Deploy em OpenShift

> Você precisa estar **logado em um cluster OpenShift**. Em clusters Kubernetes puros, o recurso `Route` não existe e causará erro.

### 6.1 Preparar namespace e ImageStream
```bash
oc apply -f openshift/namespace.yaml
oc project devsecops-demo
oc apply -f openshift/imagestream.yaml
```

### 6.2 Build e push da imagem para o registro interno (exemplos)
**Opção A: usar o registro interno (com oc)**
```bash
# Faça login no registry interno do OpenShift se necessário
docker build -t secure-pyapp:latest app

# Tag para o internal registry (ajuste o host conforme seu cluster)
docker tag secure-pyapp:latest   image-registry.openshift-image-registry.svc:5000/devsecops-demo/secure-pyapp:latest

# Faça o push (é preciso estar autenticado no registry interno)
docker push image-registry.openshift-image-registry.svc:5000/devsecops-demo/secure-pyapp:latest
```

**Opção B: usar Docker Hub e criar um ImageStream que rastreia sua imagem pública**
- Atualize `openshift/deployment.yaml` para apontar para `docker.io/<usuario>/secure-pyapp:latest`.

### 6.3 Aplicar Deployment/Service/Route
```bash
oc apply -f openshift/deployment.yaml
```

### 6.4 Acessar a aplicação
```bash
oc get route secure-pyapp -n devsecops-demo
# Copie a URL e abra no navegador
```

---

## 7) Deploy genérico em Kubernetes (opcional)
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
kubectl get svc secure-pyapp
```

---

## 8) Estrutura do projeto
```
.
├── app/                # FastAPI + métricas + Vault
├── security/           # Trivy & OWASP ZAP scripts
├── monitoring/         # Prometheus & Grafana provisioning
├── vault/              # Inicialização KV e demo secret
├── k8s/                # Manifests para Kubernetes
├── openshift/          # Manifests para OpenShift (DeploymentConfig + Route)
├── docker-compose.yml  # Orquestração local por perfis
├── Jenkinsfile         # Pipeline completo (CI/CD + segurança)
└── README.md
```

---

## 9) Boas práticas e padrões adotados
- **Security by default**: usuário não-root, dependências mínimas, probes, SAST/SCA/DAST no pipeline.
- **Privacy by design**: segredos via Vault (com fallback controlado por envs), nada hard-coded em código.
- **Observabilidade**: endpoint `/metrics` pronto para Prometheus, dashboard básico no Grafana.
- **Mentoria & Documentação**: README didático com passos claros para Docker e OpenShift.

---

## 10) Limpeza
```bash
docker compose down -v
```

---

Dúvidas? Abra issues e siga iterando: DevSecOps é **melhoria contínua**.
