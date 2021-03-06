variable "do_token" {
  type        = "string"
  description = "Digital Ocean API token"
}

variable "runscope_token" {
  type        = "string"
  description = "Runscope API token"
}

variable "runscope_team" {
  type        = "string"
  description = "Team UUID for Runscope Buckets"
  default     = "foo-bar"
}

variable "region" {
  type        = "string"
  description = "Region in which to deploy services"
  default     = "lon1"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "k8s_version" {
  default = "v1.10.3"
}

variable "cni_version" {
  default = "v0.6.0"
}

variable "healthcheck_port" {
  default = 8080
}

variable "healthcheck_tls_private_key" {
  default = ".secrets/selfsigned/key.pem"
}

variable "healthcheck_tls_cert" {
  default = ".secrets/selfsigned/certificate.pem"
}

variable "healthcheck_tls_chain" {
  default = ".secrets/selfsigned/chain"
}

variable "weather_tls_private_key" {
  default = ".secrets/selfsigned2/key.pem"
}

variable "weather_tls_cert" {
  default = ".secrets/selfsigned2/certificate.pem"
}

variable "weather_tls_chain" {
  default = ".secrets/selfsigned2/chain"
}
