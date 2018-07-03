variable "loadbalancer_tag" {
  default = "worker"
}

variable "app_port" {
  default = 8000
}

variable "subdomain" {
  default = "weather"
}

variable "domain" {
  default = "jspc.pw"
}

variable "tls_private_key" {
  default = ".secrets/selfsigned/key.pem"
}

variable "tls_cert" {
  default = ".secrets/selfsigned/certificate.pem"
}

variable "tls_chain" {
  default = ".secrets/selfsigned/chain"
}
