output "fqdn" {
  description = "Fully qualified domain name for this frontend service"
  value = "${digitalocean_record.loadbalancer.fqdn}"
}

output "lb_ip" {
  description = "IP address of loadbalancer"
  value = "${digitalocean_loadbalancer.public.ip}"
}
