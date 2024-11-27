resource "kubernetes_ingress_v1" "linkahead-ingress" {
  metadata {
    name      = "${var.instance-name}-ingress"
    namespace = var.namespace
    annotations = {
      #"nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      #"nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/${var.instance-name}/linkahead(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.linkahead-service.metadata.0.name
              port {
                number = var.linkahead-port
              }
            }
          }
        }
      }
    }
  }
}
