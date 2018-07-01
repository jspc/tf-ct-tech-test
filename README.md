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
$ export TF_VAR_do_token=<digitalocean token> TF_VAR_runscope_token=<runscope api token>
$ terraform init
```

It can be tested and run as per:

```bash
$ terraform plan
$ terraform apply
```
