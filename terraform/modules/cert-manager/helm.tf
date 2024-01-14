resource "helm_release" "this" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.13.3"
  namespace        = kubernetes_namespace.cm.metadata[0].name
  create_namespace = false

  set {
    name  = "extraArgs"
    value = "{--dns01-recursive-nameservers=\"8.8.8.8:53\",--dns01-recursive-nameservers-only}"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}