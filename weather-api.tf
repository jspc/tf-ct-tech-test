module "weather-frontend" {
  source           = "./frontend"
  loadbalancer_tag = "${digitalocean_tag.worker.name}"
  app_port         = "8000"
  subdomain        = "weather"
  domain           = "jspc.pw"
  tls_private_key  = "${var.weather_tls_private_key}"
  tls_cert         = "${var.weather_tls_cert}"
  tls_chain        = "${var.weather_tls_chain}"
}
