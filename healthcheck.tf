resource "digitalocean_certificate" "loadbalancer" {
  name              = "jspc.pw"
  private_key       = "${file(var.tls_private_key)}"
  leaf_certificate  = "${file(var.tls_cert)}"
  certificate_chain = "${file(var.tls_chain)}"
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "healthcheck-public" {
  name                   = "healthcheck-public"
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
    port     = 8080
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

resource "kubernetes_service" "healthcheck" {
  metadata {
    name = "cluster-healthcheck"
  }

  spec {
    selector {
      app = "${kubernetes_pod.healthcheck.metadata.0.labels.app}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 8080
      target_port = 8080
    }

    type         = "NodePort"
    external_ips = ["${digitalocean_droplet.worker.*.ipv4_address_private}"]
  }
}

resource "kubernetes_pod" "healthcheck" {
  metadata {
    name = "cluster-healthcheck"

    labels {
      app = "cluster-healthcheck"
    }
  }

  spec {
    container {
      image = "jspc/dumbcheck"
      name  = "healthcheck"
    }
  }
}

resource "runscope_step" "healthcheck" {
  bucket_id = "${runscope_bucket.k8s.id}"
  test_id   = "${runscope_test.healthcheck.id}"
  step_type = "request"
  url       = "https://${digitalocean_record.loadbalancer.fqdn}"
  method    = "GET"

  variables = [
    {
      name   = "httpStatus"
      source = "response_status"
    },
    {
      name     = "httpContentEncoding"
      source   = "response_header"
      property = "Content-Encoding"
    },
  ]

  assertions = [
    {
      source     = "response_status"
      comparison = "equal_number"
      value      = "200"
    },
    {
      source     = "response_json"
      comparison = "equal"
      value      = "ok"
      property   = "message"
    },
  ]

  headers = [
    {
      header = "Accept-Encoding"
      value  = "application/json"
    },
  ]
}

resource "runscope_test" "healthcheck" {
  bucket_id   = "${runscope_bucket.k8s.id}"
  name        = "Kubernetes Dumbcheck"
  description = "Is my cluster up?"
}

resource "runscope_bucket" "k8s" {
  name      = "k8s"
  team_uuid = "${var.runscope_team}"
}
