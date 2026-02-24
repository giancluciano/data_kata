variable "kafka_namespace" {
  description = "Kubernetes namespace for Kafka"
  type        = string
  default     = "kafka"
}

variable "ingestion_namespace" {
  description = "Kubernetes namespace for the ingestion job"
  type        = string
  default     = "ingestion"
}

variable "ingestion_image" {
  description = "Docker image for the ingestion pipeline. Build it into Minikube first: eval $(minikube docker-env) && docker build -f docker/ingestion/Dockerfile -t datakata-ingestion:latest ."
  type        = string
  default     = "datakata-ingestion:latest"
}
