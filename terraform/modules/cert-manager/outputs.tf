output "staging_ssl_cert_secret_name" {
    value = local.staging_secret_name
}

output "prod_ssl_cert_secret_name" {
    value = local.prod_secret_name
}