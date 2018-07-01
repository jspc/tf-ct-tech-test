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
