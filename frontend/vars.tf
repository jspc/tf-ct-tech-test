variable "loadbalancer_tag" {
  description = "Digital Ocean tag on droplets which will sit behind firewall"
  default     = "worker"
  type        = "string"
}

variable "app_port" {
  description = "Port on droplets which will be fronted with loadbalancer"
  default     = 8000
}

variable "subdomain" {
  description = "Subdomain on which to create DNS records"
  default     = "weather"
  type        = "string"
}

variable "domain" {
  description = "Domain on which to create DNS records"
  default     = "jspc.pw"
  type        = "string"
}

variable "tls_private_key" {
  description = "Private Key for TLS certs"
  default     = ".secrets/selfsigned/key.pem"
  type        = "string"
}

variable "tls_cert" {
  description = "TLS Certificate"
  default     = ".secrets/selfsigned/certificate.pem"
  type        = "string"
}

// Originally I aimed to use a ternary here to determine whether the variable was empty as per:
//    "${var.tls_chain == "" ? "" : file(var.tls_chain)}"
// This wont work because terraform evaluates both sides of the ternary before choosing one.
// See: https://github.com/hashicorp/hil/issues/50
variable "tls_chain" {
  description = "TLS Trust Chain. This must be set, though may be an empty file"
  default     = ".secrets/selfsigned/chain"
  type        = "string"
}
