output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers within the cluster"
  value       = module.kafka.bootstrap_servers
}

output "kafka_namespace" {
  value = module.kafka.namespace
}

output "ingestion_namespace" {
  value = kubernetes_namespace_v1.ingestion.metadata[0].name
}
