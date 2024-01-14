locals {
  letsencrypt_prod_server_url    = "https://acme-v02.api.letsencrypt.org/directory"
  letsencrypt_staging_server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  prod_secret_name = "${var.domain}-ssl-cert-production"
  staging_secret_name = "${var.domain}-ssl-cert-staging"
}

resource "kubernetes_namespace" "cm" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret_v1" "cert-manager" {
  metadata {
    name      = "cert-manager"
    namespace = kubernetes_namespace.cm.metadata[0].name
  }

  data = {
    "secret-access-key" = aws_iam_access_key.cert-manager.secret
  }
}

resource "kubernetes_manifest" "clusterissuer_cert_manager_letsencrypt_staging" {
  count = var.create_letsencrypt_issuers == true ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-staging"
    }
    "spec" = {
      "acme" = {
        "email" = var.email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-staging"
        }
        "server" = local.letsencrypt_staging_server_url
        "solvers" = [
          {
            "dns01" = {
              "route53" = {
                "accessKeyID" = aws_iam_access_key.cert-manager.id
                "region"      = "us-east-1"
                "secretAccessKeySecretRef" = {
                  "name" = kubernetes_secret_v1.cert-manager.metadata[0].name
                  "key"  = "secret-access-key"
                }
              }
            }
            "selector" = {}
          },
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "clusterissuer_cert_manager_letsencrypt_production" {
  count = var.create_letsencrypt_issuers == true ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "email" = var.email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-production"
        }
        "server" = local.letsencrypt_prod_server_url
        "solvers" = [
          {
            "dns01" = {
              "route53" = {
                "accessKeyID" = aws_iam_access_key.cert-manager.id
                "region"      = "us-east-1"
                "secretAccessKeySecretRef" = {
                  "name" = kubernetes_secret_v1.cert-manager.metadata[0].name
                  "key"  = "secret-access-key"
                }
              }
            }
            "selector" = {}
          },
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "k3s_domain_ssl_cert_staging" {
    count = var.create_letsencrypt_certs == true ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = local.staging_secret_name
      "namespace" = "cert-manager"
    }
    "spec" = {
      "commonName" = var.domain
      "dnsNames" = [var.domain]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt-staging"
      }
      "secretName" = local.staging_secret_name
    }
  }
}

resource "kubernetes_manifest" "k3s_domain_ssl_cert_prod" {
    count = var.create_letsencrypt_certs == true ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = local.prod_secret_name
      "namespace" = "cert-manager"
    }
    "spec" = {
      "commonName" = var.domain
      "dnsNames" = [var.domain]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt-production"
      }
      "secretName" = local.prod_secret_name
    }
  }
}
