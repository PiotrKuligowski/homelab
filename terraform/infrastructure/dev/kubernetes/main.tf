module "ingress-controller" {
  source = "../../../modules/nginx-ingress-controller"
}

module "cert-manager" {
  source                     = "../../../modules/cert-manager"
  domain                     = var.domain
  email                      = var.email
  create_letsencrypt_issuers = true
  create_letsencrypt_certs   = true
}
