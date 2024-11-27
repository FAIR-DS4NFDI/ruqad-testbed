resource "kubernetes_deployment" "linkahead" {
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
          image = local.linkahead-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.linkahead-env.metadata[0].name
            }
          }
          port {
            container_port = 10080
            name           = "linkahead-port"
          }

          # dynamic "volume_mount" {
          #   for_each = toset(var.init-sql-configs)
          #   content {
          #     mount_path = "/docker-entrypoint-initdb.d/${volume_mount.value}.sql"
          #     name       = volume_mount.value
          #     sub_path   = "${volume_mount.value}.sql"
          #     read_only  = true
          #   }
          # }

          # Uncomment this to assign (more) resources
          #          resources {
          #            limits = {
          #              cpu    = "2"
          #              memory = "512Mi"
          #            }
          #            requests = {
          #              cpu    = "250m"
          #              memory = "50Mi"
          #            }
          #          }
          liveness_probe {
            tcp_socket {
              port = var.linkahead-port
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }

        # dynamic "volume" {
        #   for_each = toset(var.init-sql-configs)
        #   content {
        #     name = volume.value
        #     config_map {
        #       name = volume.value
        #     }
        #   }
        # }
      }
    }
  }
}

resource "kubernetes_config_map" "linkahead-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    CAOSDB_CONFIG_AUTH_OPTIONAL = "TRUE"
    CAOSDB_CONFIG_MYSQL_HOST = local.mariadb-host
    CAOSDB_CONFIG_MYSQL_PORT = local.mariadb-port
    CAOSDB_CONFIG_CONTEXT_ROOT = "/${var.instance-name}/linkahead"
    NO_TLS = "1"
    DEBUG = "1"
  }
}

resource "kubernetes_service" "linkahead-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.linkahead.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "linkahead-port"
      port        = var.linkahead-port
      target_port = 10080
    }
  }
}

locals {
  mariadb-host = "${var.instance-name}-mariadb-service"
  mariadb-port = 3306
  app-name = "${var.instance-name}-linkahead"
  linkahead-image = "indiscale/linkahead:dev"
}
