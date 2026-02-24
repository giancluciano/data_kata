# ── Kafka ────────────────────────────────────────────────────────────────────
module "kafka" {
  source        = "../../modules/kafka"
  namespace     = var.kafka_namespace
  replica_count = 1
  storage_size  = "2Gi"
}

# ── Ingestion namespace ───────────────────────────────────────────────────────
resource "kubernetes_namespace_v1" "ingestion" {
  metadata {
    name = var.ingestion_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# ── Config passed into the ingestion Job ─────────────────────────────────────
resource "kubernetes_config_map_v1" "ingestion" {
  metadata {
    name      = "ingestion-config"
    namespace = kubernetes_namespace_v1.ingestion.metadata[0].name
  }

  data = {
    KAFKA_BOOTSTRAP_SERVERS = module.kafka.bootstrap_servers
    PRODUCTS_TOPIC          = "products-raw"
    PRODUCTS_CSV_PATH       = "/data/products.csv"
  }
}

# ── Ingestion Job (runs once, reads CSV → publishes to Kafka) ─────────────────
# Build the image into Minikube before applying:
#   eval $(minikube docker-env)
#   docker build -f docker/ingestion/Dockerfile -t datakata-ingestion:latest .
resource "kubernetes_job_v1" "filesystem_ingestion" {
  metadata {
    name      = "filesystem-ingestion"
    namespace = kubernetes_namespace_v1.ingestion.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "filesystem-ingestion"
      "app.kubernetes.io/component"  = "ingestion"
    }
  }

  spec {
    backoff_limit = 3

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "filesystem-ingestion"
        }
      }

      spec {
        restart_policy = "Never"

        container {
          name              = "filesystem-producer"
          image             = var.ingestion_image
          image_pull_policy = "IfNotPresent"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.ingestion.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  wait_for_completion = false
  depends_on          = [module.kafka]
}
