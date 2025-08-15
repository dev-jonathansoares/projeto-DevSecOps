# Jenkins with Docker CLI, kubectl and kind preinstalled
FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release git jq \
    docker.io \
 && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -fsSL https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install kind
RUN curl -fsSL https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 -o /usr/local/bin/kind \
 && chmod +x /usr/local/bin/kind

# Docker group to access host docker socket
RUN groupadd -g 999 docker || true && usermod -aG docker jenkins

USER jenkins
