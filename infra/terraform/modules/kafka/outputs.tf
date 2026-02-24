output "namespace" {
  description = "Kubernetes namespace where Kafka is deployed"
  value       = var.namespace
}

output "bootstrap_servers" {
  description = "Kafka bootstrap servers reachable within the cluster"
  value       = "kafka.${var.namespace}.svc.cluster.local:9092"
}
