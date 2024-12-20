resource "kubernetes_ingress_v1" "kadi-ingress" {
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
          path = "/${var.instance-name}(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.kadi-service.metadata.0.name
              port {
                number = var.kadi-port
              }
            }
          }
        }
      }
    }
  }
}
