locals {
  domain_name = "${var.subdomain}.${var.domain}"
}

resource "digitalocean_certificate" "loadbalancer" {
  name              = "${local.domain_name}"
  private_key       = "${file(var.tls_private_key)}"
  leaf_certificate  = "${file(var.tls_cert)}"
  certificate_chain = "${file(var.tls_chain)}"
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "public" {
  name                   = "${local.domain_name}"
  region                 = "lon1"
  droplet_tag            = "${var.loadbalancer_tag}"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = "${var.app_port}"
    target_protocol = "http"

    certificate_id = "${digitalocean_certificate.loadbalancer.id}"
  }

  healthcheck {
    port     = "${var.app_port}"
    protocol = "tcp"
  }
}

resource "digitalocean_record" "loadbalancer" {
  domain = "${var.domain}"
  type   = "A"
  name   = "${var.subdomain}"
  ttl    = 30
  value  = "${digitalocean_loadbalancer.public.ip}"
}
