resource "digitalocean_certificate" "loadbalancer" {
  name              = "jspc.pw"
  private_key       = "${file(var.tls_private_key)}"
  leaf_certificate  = "${file(var.tls_cert)}"
  certificate_chain = "${file(var.tls_chain)}"
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "healthcheck-public" {
  name                   = "k8s-tls"
  region                 = "lon1"
  droplet_tag            = "${digitalocean_tag.worker.name}"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = "${var.healthcheck_port}"
    target_protocol = "http"

    certificate_id = "${digitalocean_certificate.loadbalancer.id}"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }
}

resource "digitalocean_record" "loadbalancer" {
  domain = "jspc.pw"
  type   = "A"
  name   = "lb"
  ttl    = 30
  value  = "${digitalocean_loadbalancer.healthcheck-public.ip}"
}
