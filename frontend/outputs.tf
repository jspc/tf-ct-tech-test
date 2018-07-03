output "fqdn" {
  value = "${digitalocean_record.loadbalancer.fqdn}"
}
