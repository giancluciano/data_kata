# Local Setup Guide

This guide covers the installation of Terraform, Kubernetes tools, and Helm for local development.

## OS Requirements

| Tool | Linux | macOS |
|------|-------|-------|
| Terraform | Ubuntu 18.04+, Debian 10+, RHEL 7+, CentOS 7+ | macOS 10.15+ |
| kubectl | Kernel 3.10+ | macOS 10.15+ |
| Minikube | 2 CPUs, 2GB RAM, 20GB disk | 2 CPUs, 2GB RAM, 20GB disk |
| Helm | glibc-based Linux | macOS 10.15+ |

### Prerequisites

- 64-bit operating system
- Virtualization enabled in BIOS (for Minikube)
- Container runtime: Docker or Podman

---

## Terraform Installation

### Linux (Debian/Ubuntu)

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install
sudo apt update && sudo apt install terraform
```

### macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Verify Installation

```bash
terraform --version
```

---

## Kubernetes Installation

### kubectl

#### Linux

```bash
# Download latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### macOS

```bash
brew install kubectl
```


#### Verify Installation

```bash
kubectl version --client
```

---

### Minikube (Local Kubernetes Cluster)

#### Linux

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### macOS

```bash
brew install minikube
```

#### Start Minikube

```bash
minikube start --cpus=4 --memory=8192 --driver=docker
```

---

## Helm Installation

Helm is the package manager for Kubernetes, used to deploy complex applications like Kafka (Strimzi), Spark operator, and Flink.

### Linux

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### macOS

```bash
brew install helm
```

### Verify Installation

```bash
helm version
```
---

## Verify Setup

```bash
# Check Terraform
terraform --version

# Check kubectl
kubectl version --client

# Check Helm
helm version

# Check cluster connection (after starting minikube or kind)
kubectl cluster-info
kubectl get nodes

# Check Helm repos
helm repo list
```
