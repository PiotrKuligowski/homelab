resource "helm_release" "this" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.0"

  set {
    name  = "controller.publishService.enabled"
    value = true
  }
}
