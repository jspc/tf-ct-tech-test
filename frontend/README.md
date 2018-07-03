Frontend Module
==

This module provides some shorthand around:
 1. Configuring a TLS cert
 1. Hooking up a Loadbalancer
 1. Setting a listener with this certificate
 1. Pointing a DNS record up to this LB

It can may be used as per:

```terraform
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app_port | Port on droplets which will be fronted with loadbalancer | string | `8000` | no |
| domain | Domain on which to create DNS records | string | `jspc.pw` | no |
| loadbalancer_tag | Digital Ocean tag on droplets which will sit behind firewall | string | `worker` | no |
| subdomain | Subdomain on which to create DNS records | string | `weather` | no |
| tls_cert | TLS Certificate | string | `.secrets/selfsigned/certificate.pem` | no |
| tls_chain | TLS Trust Chain. This must be set, though may be an empty file | string | `.secrets/selfsigned/chain` | no |
| tls_private_key | Private Key for TLS certs | string | `.secrets/selfsigned/key.pem` | no |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | Fully qualified domain name for this frontend service |
| lb_ip | IP address of loadbalancer |

