.PHONY: build up logs down test clean ci-up ci-down kind-setup k8s-apply k8s-forward

build:
	docker build -t hits-api:local .

up:
	docker compose up --build -d

logs:
	docker compose logs -f

down:
	docker compose down

test:
	curl -s http://localhost:5001/health | jq . || curl -s http://localhost:5001/health

clean:
	docker compose down -v || true
	docker rmi hits-api:local || true

# CI stack (Jenkins + SonarQube)
ci-up:
	docker compose -f docker-compose.ci.yml up -d --build

ci-down:
	docker compose -f docker-compose.ci.yml down -v

# Kind + K8s
kind-setup:
	bash scripts/kind-setup.sh

k8s-apply:
	kubectl apply -f k8s/

k8s-forward:
	kubectl port-forward svc/hits-api 5001:5001
