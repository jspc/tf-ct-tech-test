tf-ct-tech-test
==

Deploy k8s into Digital Ocean (the hard way). This project will:

 * Spin up a K8s cluster of one master, two workers to Digital Ocean
 * Join these machines
 * Deploy a canary service (Which will return simple healthcheck)
 * Deploy a loadbalancer to front it
 * Point a DNS entry to this loadbalancer
 * Hook up some runscope monitoring in front of it

After this, other services can be deployed to the cluster

## Usage

This repo requires:

* provider.digitalocean: version = "~> 0.1"
* provider.kubernetes: version = "~> 1.1"
* provider.null: version = "~> 1.0"
* provider.runscope: version = "~> 0.1"

It can be bootstrapped via:

```bash
$ export TF_VAR_do_token=<digital ocean API key>
$ export TF_VAR_runscope_token=<runscope API key>
$ export TF_VAR_runscope_team=<runscope Team UUID>
$ export TF_VAR_ssh_private_key=<private key to connect to hosts via>
$ export TF_VAR_ssh_public_key=<public key to put on instances>

$ terraform init
```

It can be tested and run as per:

```bash
$ terraform plan
$ terraform apply
```

### A note on TLS

This config uses a self signed certificate. The variables:

```hcl
variable "tls_private_key" {
  default = ".secrets/selfsigned/key.pem"
}

variable "tls_cert" {
  default = ".secrets/selfsigned/certificate.pem"
}

variable "tls_chain" {
  default = ".secrets/selfsigned/chain"
}
```

Can all be overridden with real keys.

## Monitoring

This cluster runs github.com/jspc/dumbcheck as a very naive healthcheck, which is then hit by runscope to provide a really basic canary healthcheck.
