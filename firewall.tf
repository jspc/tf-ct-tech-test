resource "digitalocean_firewall" "all-out" {
  name = "all-out"

  droplet_ids = ["${concat(list(digitalocean_droplet.master.id), digitalocean_droplet.worker.*.id)}"]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "ssh" {
  name = "ssh"

  droplet_ids = ["${concat(list(digitalocean_droplet.master.id), digitalocean_droplet.worker.*.id)}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "kubectl" {
  name = "kubectl"

  droplet_ids = ["${digitalocean_droplet.master.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "6443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "internal" {
  name = "internal"

  droplet_ids = ["${concat(list(digitalocean_droplet.master.id), digitalocean_droplet.worker.*.id)}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "1-65535"
      source_addresses = ["10.0.0.0/8", "${digitalocean_loadbalancer.healthcheck-public.ip}"]
    },
    {
      protocol         = "udp"
      port_range       = "1-65535"
      source_addresses = ["10.0.0.0/8", "${digitalocean_loadbalancer.healthcheck-public.ip}"]
    },
    {
      protocol         = "icmp"
      source_addresses = ["10.0.0.0/8"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["10.0.0.0/8"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["10.0.0.0/8"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["10.0.0.0/8"]
    },
  ]
}
