# Ingestion Layer — Local Setup & Run Guide

Runs the filesystem ingestion pipeline (CSV → Kafka) on a local Minikube cluster using Terraform.

## Prerequisites

Make sure the tools below are installed. See [LOCAL_SETUP.md](LOCAL_SETUP.md) for installation instructions.

| Tool | Min version |
|------|-------------|
| Minikube | 1.33+ |
| kubectl | 1.29+ |
| Helm | 3.14+ |
| Terraform | 1.5+ |
| Docker | 24+ |

---

## 1. Start Minikube

```bash
minikube start --cpus=6 --memory=8192 --driver=docker
```

Verify the cluster is up:

```bash
kubectl cluster-info
kubectl get nodes
```

---

## 2. Add the Strimzi Helm repository

Apache Kafka is deployed via the [Strimzi operator](https://strimzi.io).

```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
```

Verify the chart is available:

```bash
helm search repo strimzi/strimzi-kafka-operator
```

---

## 3. Build the ingestion Docker image into Minikube

Point your local Docker CLI at Minikube's daemon so the image is available inside the cluster without a registry.

```bash
eval $(minikube docker-env)
docker build -f docker/ingestion/Dockerfile -t datakata-ingestion:latest .
```

> Run `eval $(minikube docker-env --unset)` to restore your normal Docker environment afterwards.

---

## 4. Apply Terraform

Strimzi installs Custom Resource Definitions (CRDs) via Helm. Terraform must resolve those CRDs before it can plan the Kafka cluster manifest, so a **two-step apply** is required on the first run:

```bash
cd infra/terraform/environments/local
terraform init

# Step 1 — install the Strimzi operator and its CRDs
terraform apply -target=module.kafka.helm_release.strimzi_operator

# Step 2 — deploy the Kafka cluster, topics, and ingestion job
terraform apply
```

Terraform will:
1. Create namespaces `kafka` and `ingestion`
2. Deploy the Strimzi operator (Apache Kafka on Kubernetes)
3. Create the `sales-kafka` cluster with topics `products-raw`, `sales-raw`, `sales-dlq`
4. Run the `filesystem-ingestion` Kubernetes Job

---

## 5. Monitor the ingestion job

```bash
# Watch job status
kubectl get job filesystem-ingestion -n ingestion -w

# Stream logs
kubectl logs -n ingestion job/filesystem-ingestion -f
```

A successful run ends with:

```
Ingestion complete — published 10 products to 'products-raw'
Ingestion pipeline finished
```

---

## 6. Debug

```bash
# All resources across namespaces
kubectl get all -A

# Events (sorted by time) — first place to look when a pod won't start
kubectl get events -n kafka --sort-by='.lastTimestamp'
kubectl get events -n ingestion --sort-by='.lastTimestamp'

# Describe a failing pod
kubectl describe pod -n kafka -l app.kubernetes.io/name=kafka
kubectl describe pod -n ingestion -l app.kubernetes.io/name=filesystem-ingestion

# Logs with previous crash output
kubectl logs -n ingestion job/filesystem-ingestion --previous
```

---

## 7. Verify messages in Kafka

Open a shell inside the Kafka pod:

```bash
kubectl exec -it -n kafka \
  $(kubectl get pod -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}') \
  -- bash
```

Then consume from the topic:

```bash
kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic products-raw \
  --from-beginning
```

---

## Tear down

```bash
terraform destroy
minikube stop
```

---

## Configuration reference

All ingestion settings are injected via the `ingestion-config` ConfigMap and can be overridden with Terraform variables.

| Variable | Default | Description |
|----------|---------|-------------|
| `kafka_namespace` | `kafka` | K8s namespace for Kafka |
| `ingestion_namespace` | `ingestion` | K8s namespace for the ingestion job |
| `ingestion_image` | `datakata-ingestion:latest` | Docker image to use |

Override at apply time:

```bash
terraform apply \
  -var="ingestion_image=datakata-ingestion:v1.0.0"
```
