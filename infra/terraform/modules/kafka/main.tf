terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
  }
}

resource "kubernetes_namespace_v1" "kafka" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# ── Strimzi operator (installs Apache Kafka CRDs + controller) ────────────────
resource "helm_release" "strimzi_operator" {
  name             = "strimzi-kafka-operator"
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false
  wait             = true
  timeout          = 300

  values = [file("${path.module}/values.yaml")]

  depends_on = [kubernetes_namespace_v1.kafka]
}

# ── Kafka cluster CR ──────────────────────────────────────────────────────────
# NOTE: First apply must target the operator so its CRDs exist before plan
# resolves this manifest:
#   terraform apply -target=helm_release.strimzi_operator
#   terraform apply
resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = "sales-kafka"
      namespace = var.namespace
    }
    spec = {
      kafka = {
        version  = "3.9.0"
        replicas = var.replica_count
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          }
        ]
        config = {
          "offsets.topic.replication.factor"         = tostring(var.replica_count)
          "transaction.state.log.replication.factor" = tostring(var.replica_count)
          "transaction.state.log.min.isr"            = "1"
          "default.replication.factor"               = tostring(var.replica_count)
          "min.insync.replicas"                      = "1"
        }
        storage = {
          type = "jbod"
          volumes = [
            {
              id          = 0
              type        = "persistent-claim"
              size        = var.storage_size
              deleteClaim = true
            }
          ]
        }
      }
      zookeeper = {
        replicas = var.replica_count
        storage = {
          type        = "persistent-claim"
          size        = "2Gi"
          deleteClaim = true
        }
      }
      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }

  depends_on = [helm_release.strimzi_operator]
}

# ── Kafka topics ──────────────────────────────────────────────────────────────
resource "kubernetes_manifest" "topic_products_raw" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "products-raw"
      namespace = var.namespace
      labels    = { "strimzi.io/cluster" = "sales-kafka" }
    }
    spec = {
      partitions = 3
      replicas   = var.replica_count
      config     = { "cleanup.policy" = "compact" }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

resource "kubernetes_manifest" "topic_sales_raw" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "sales-raw"
      namespace = var.namespace
      labels    = { "strimzi.io/cluster" = "sales-kafka" }
    }
    spec = {
      partitions = 3
      replicas   = var.replica_count
      config     = { "retention.ms" = "604800000" }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

resource "kubernetes_manifest" "topic_sales_dlq" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "sales-dlq"
      namespace = var.namespace
      labels    = { "strimzi.io/cluster" = "sales-kafka" }
    }
    spec = {
      partitions = 1
      replicas   = var.replica_count
      config     = { "retention.ms" = "2592000000" }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}
