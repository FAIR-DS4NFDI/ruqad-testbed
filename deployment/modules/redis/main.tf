#
#  Copyright (c) 2024 Metaform Systems, Inc.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
#
#  Contributors:
#       Metaform Systems, Inc. - initial API and implementation
#

resource "kubernetes_deployment" "redis" {
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
          image = local.redis-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.redis-env.metadata[0].name
            }
          }
          port {
            container_port = 6379
            name           = "redis-port"
          }

          liveness_probe {
            tcp_socket {
              port = var.database-port
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

resource "kubernetes_config_map" "redis-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
  }
}

resource "kubernetes_service" "redis-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.redis.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "redis-port"
      port        = var.database-port
      target_port = var.database-port
    }
  }
}

locals {
  app-name = "${var.instance-name}-redis"
  redis-image = "redis:7-alpine"
  db-ip    = kubernetes_service.redis-service.spec.0.cluster_ip
  db-url   = "${kubernetes_service.redis-service.metadata[0].name}:${var.database-port}"
}
