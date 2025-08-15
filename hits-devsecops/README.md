# HITS DevSecOps Demo (porta 5001) ✅

Projeto **simples e funcional** para entrevista técnica:
- API **FastAPI** (porta **5001**, não usa 8080)
- **Docker / Docker Compose**
- **CI/CD com Jenkins** (UI em **8090**)
- **SonarQube** (em **9000**)
- **Kubernetes com kind** (NodePort **30081**)

> Nome da empresa aplicado: **HITS**

---

## 📦 Estrutura

```
.
├── app/
│   └── main.py
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kind-config.yaml
├── scripts/
│   └── kind-setup.sh
├── Dockerfile
├── Jenkins.Dockerfile
├── Jenkinsfile
├── docker-compose.yml          # roda apenas a API local
├── docker-compose.ci.yml       # sobe Jenkins + Sonar
├── requirements.txt
├── sonar-project.properties
├── .env.sample
└── Makefile
```

---

## 🚀 Rodar só a API (rápido)

```bash
cp .env.sample .env
docker compose up --build -d
curl http://localhost:5001/health
```

---

## ☸️ Kubernetes com kind (funcionando)

1) **Criar cluster** com porta do NodePort exposta:
```bash
make kind-setup
```
Isso cria/ajusta kubeconfig para uso de **containers** também (endereço do API server).

2) **Carregar imagem** e **aplicar manifests**:
```bash
docker build -t hits-api:local .
kind load docker-image hits-api:local
make k8s-apply
kubectl get pods -w
```

3) **Acessar app via NodePort**:
- Navegador/CLI: `http://localhost:30081/health`  
- Ou via port-forward:
```bash
make k8s-forward
curl http://localhost:5001/health
```

---

## 🧰 Subir **Jenkins + SonarQube** (CI/CD)

> Portas: Jenkins **8090**, Sonar **9000**.

1) **Subir o stack**:
```bash
make ci-up
```

2) **Primeiro acesso ao Jenkins**:  
Abra `http://localhost:8090`. Usuário inicial é criado; se o wizard estiver ativo, a senha inicial está em:
```bash
docker exec -it hits-jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword'
```
Crie um admin e **instale plugins sugeridos**.

3) **Acessar SonarQube**:  
`http://localhost:9000` (login: `admin` / senha: `admin` na primeira vez, ele pede para trocar).  
Crie um **token** (Administration → Security → Users → Tokens).

4) **Credenciais no Jenkins**:
- `sonar-token` (**Secret Text**) com o token gerado no Sonar.
- (Opcional) `dockerhub` (Username/Password) se quiser fazer **push** para o Docker Hub.

5) **Criar um Pipeline** no Jenkins:  
- *New Item* → **Pipeline** → em *Pipeline script*, **cole** o conteúdo do `Jenkinsfile` deste projeto → Salve.
- Execute o pipeline.

O pipeline faz:
- **Build** da imagem Docker `hits-api:${BUILD_NUMBER}`
- **Análise SAST** com **SonarQube** (usando container `sonarsource/sonar-scanner-cli`)
- **Cria/garante** um cluster **kind** (dentro do Jenkins)
- Conecta o container do Jenkins à rede `kind`
- **Ajusta kubeconfig** para uso em container
- **Carrega a imagem** no kind (`kind load docker-image`)
- **Aplica manifests** e **troca a imagem** do Deployment para a tag do build
- Aguarda o **rollout**

> Observação: O `docker-compose.ci.yml` já conecta o Jenkins à rede externa `kind`. Se você subir o cluster **depois**, re-criar a stack (ou `docker network connect kind hits-jenkins`) garante a conectividade.

6) **Verificando o deploy**:
```bash
kubectl get deploy,pods,svc
curl http://localhost:30081/health
```

7) **Derrubar o stack CI**:
```bash
make ci-down
```

---

## 🔎 Explicação de cada ação (resumo de entrevista)

- **Containerização**: Dockerfile enxuto com base `python:3.11-slim`, **HEALTHCHECK** e porta **5001**.  
- **Configuração**: `.env` controlando `APP_ENV`, `GREETING` e `VERSION`.  
- **Kubernetes (kind)**: Deployment com probes, Service NodePort **30081**; `kind-config.yaml` expõe a porta no host.  
- **CI/CD com Jenkins**: Pipeline em **stages** (build, scan, cluster, deploy). Jenkins roda em **8090** para evitar conflitos.  
- **Qualidade (SonarQube)**: `sonar-scanner` roda via container, lê `sonar-project.properties` e publica resultados no Sonar.  
- **Entrega contínua**: `kind load docker-image` e `kubectl set image` trocam a versão em produção (cluster local).  
- **Observabilidade básica**: endpoint `/health` e `/version` para diagnósticos rápidos.

---

## 🔐 Notas e portas

- **Sem 8080** no host:
  - API: **5001**
  - Jenkins: **8090**
  - SonarQube: **9000**
  - NodePort K8s: **30081**

- Caso rode em Windows/WSL2: montar `/var/run/docker.sock` no Jenkins dá acesso ao Docker do host.  
- Se o `kubectl` do Jenkins não enxergar o cluster, rode novamente `make kind-setup` e reinicie o Jenkins (`make ci-down && make ci-up`).

Boa sorte na entrevista! 🚀
