resource "libvirt_volume" "storage-qcow2" {
  name = join("", ["storage", var.domain_name, ".qcow2"])
  pool = "default"
  source = var.disk_image
  format = "qcow2"
}

resource "libvirt_domain" "storage" {
  name = join("", ["storage", var.domain_name])
  memory = 1024
  vcpu = 2

  network_interface {
    network_id = libvirt_network.docker-swarm.id
    hostname = join("", ["storage", var.domain_name])
    addresses = [ join("", [var.network.ipv4, 200]) ]
  }

  disk {
    volume_id = "${libvirt_volume.storage-qcow2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = 0
  }

  graphics {
    type = "spice"
    listen_address = "address"
    autoport = true
  }

  depends_on = [ libvirt_network.docker-swarm ]
}

# wait until VMs become ready
resource "terraform_data" "storage-up" {

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", ["storage", var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", ["storage", var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", ["storage", var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.storage ]
}