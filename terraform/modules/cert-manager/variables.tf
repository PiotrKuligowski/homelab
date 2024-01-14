variable "email" {
  type = string
}

variable "domain" {
  type    = string
  default = ""
}

variable "create_letsencrypt_issuers" {
  type    = bool
  default = false
}

variable "create_letsencrypt_certs" {
  type    = bool
  default = false
}