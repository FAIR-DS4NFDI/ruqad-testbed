resource "kubernetes_deployment" "kadi" {
  metadata {
    name      = local.app-name
    namespace = var.namespace
    labels = {
      App = local.app-name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = local.app-name
      }
    }
    template {
      metadata {
        labels = {
          App = local.app-name
        }
      }
      spec {
        container {
          image = local.kadi-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.kadi-env.metadata[0].name
            }
          }
          port {
            container_port = 5000
            name           = "kadi-port"
          }

          liveness_probe {
            tcp_socket {
              port = var.kadi-port
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }

      }
    }
  }
}

resource "kubernetes_config_map" "kadi-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    KADI_SQLALCHEMY_DATABASE_URI = var.sqlalchemy-database-uri
    KADI_RATELIMIT_STORAGE_URI = "memory://"
    KADI_CELERY_BROKER_URL = var.redis-uri
    KADI_SERVER_NAME = "localhost"
    KADI_APPLICATION_ROOT = "/kadi/"
  }
}

resource "kubernetes_service" "kadi-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.kadi.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "kadi-port"
      port        = var.kadi-port
      target_port = 5000
    }
  }
}

locals {
  app-name = "${var.instance-name}-kadi"
  kadi-image = "indiscale/kadi-dev:1.1.2"
}
