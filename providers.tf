provider "digitalocean" {
  token = "${var.do_token}"
}

provider "kubernetes" {
  // We will allow kubectl/ kubectl config to handle this stuff
}

provider "runscope" {
  access_token = "${var.runscope_token}"
}
