variable "namespace" {
  description = "Kubernetes namespace for Kafka"
  type        = string
  default     = "kafka"
}

variable "chart_version" {
  description = "Strimzi operator Helm chart version. Find latest: helm search repo strimzi/strimzi-kafka-operator"
  type        = string
  default     = "0.50.1"
}

variable "replica_count" {
  description = "Number of Kafka broker and ZooKeeper replicas"
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "Persistent volume size per broker"
  type        = string
  default     = "5Gi"
}
