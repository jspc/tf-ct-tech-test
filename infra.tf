resource "digitalocean_ssh_key" "core" {
  name       = "CT Tech Test"
  public_key = "${file("${var.ssh_public_key}")}"
}

resource "digitalocean_tag" "k8s" {
  name = "k8s"
}

resource "digitalocean_tag" "worker" {
  name = "worker"
}

resource "digitalocean_droplet" "master" {
  name = "k8s-master"

  image              = "coreos-stable"
  private_networking = true
  region             = "${var.region}"
  size               = "2gb"

  ssh_keys = ["${digitalocean_ssh_key.core.id}"]
  tags     = ["${digitalocean_tag.k8s.id}"]

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo mkdir -vp /opt/cni/bin /opt/bin /etc/systemd/system/kubelet.service.d",
      "curl -L https://github.com/containernetworking/plugins/releases/download/${var.cni_version}/cni-plugins-amd64-${var.cni_version}.tgz | sudo tar -C /opt/cni/bin -xz",
      "curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${var.k8s_version}/bin/linux/amd64/{kubeadm,kubelet,kubectl}",
      "sudo mv -v kube* /opt/bin",
      "sudo chmod +x /opt/bin/kube*",
      "curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/${var.k8s_version}/build/debs/kubelet.service | sed 's:/usr/bin:/opt/bin:g' > /tmp/srv && sudo mv -v /tmp/srv /etc/systemd/system/kubelet.service",
      "curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/${var.k8s_version}/build/debs/10-kubeadm.conf | sed 's:/usr/bin:/opt/bin:g' > /tmp/kubeadm && sudo mv -v /tmp/kubeadm /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",
      "sudo /opt/bin/kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${self.ipv4_address_private} --apiserver-cert-extra-sans=${self.ipv4_address}",
      "sudo /opt/bin/kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml",
      "sudo systemctl enable docker kubelet",
      "sudo /opt/bin/kubeadm token create --print-join-command > /tmp/kubeadm_join",
      "sudo chown core /etc/kubernetes/admin.conf",
    ]

    connection {
      type        = "ssh"
      user        = "core"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy secrets to local
  provisioner "local-exec" {
    command = <<EOF
            scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh_private_key} core@${digitalocean_droplet.master.ipv4_address}:"/tmp/kubeadm_join /etc/kubernetes/admin.conf" ${path.module}/.secrets/
            sed -i '.bak' "s/${self.ipv4_address_private}/${self.ipv4_address}/" ${path.module}/.secrets/admin.conf
EOF
  }
}

resource "digitalocean_droplet" "worker" {
  name  = "${format("k8s-worker-%02d", count.index)}"
  image = "coreos-stable"

  region             = "${var.region}"
  size               = "2gb"
  private_networking = true

  ssh_keys = ["${digitalocean_ssh_key.core.id}"]
  tags     = ["${digitalocean_tag.k8s.id}", "${digitalocean_tag.worker.id}"]

  provisioner "file" {
    source      = ".secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"

    connection {
      type        = "ssh"
      user        = "core"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo mkdir -vp /opt/cni/bin /opt/bin /etc/systemd/system/kubelet.service.d",
      "curl -L https://github.com/containernetworking/plugins/releases/download/${var.cni_version}/cni-plugins-amd64-${var.cni_version}.tgz | sudo tar -C /opt/cni/bin -xz",
      "curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${var.k8s_version}/bin/linux/amd64/{kubeadm,kubelet,kubectl}",
      "sudo mv -v kube* /opt/bin",
      "sudo chmod +x /opt/bin/kube*",
      "curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/${var.k8s_version}/build/debs/kubelet.service | sed 's:/usr/bin:/opt/bin:g' > /tmp/srv && sudo mv -v /tmp/srv /etc/systemd/system/kubelet.service",
      "curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/${var.k8s_version}/build/debs/10-kubeadm.conf | sed 's:/usr/bin:/opt/bin:g' > /tmp/kubeadm",
      "echo Environment=KUBELET_EXTRA_ARGS=--node-ip=${self.ipv4_address_private} >> /tmp/kubeadm",
      "sudo mv -v /tmp/kubeadm /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",
      "sudo systemctl daemon-reload",
      "sudo $(cat /tmp/kubeadm_join)",
      "sudo systemctl enable docker kubelet",
    ]

    connection {
      type        = "ssh"
      user        = "core"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "local-exec" {
    when = "destroy"

    command = <<EOF
export KUBECONFIG=${path.module}/.secrets/admin.conf
kubectl drain --delete-local-data --force --ignore-daemonsets ${self.name}
kubectl delete nodes/${self.name}
EOF
  }

  depends_on = ["digitalocean_droplet.master"]
  count      = 2
}
