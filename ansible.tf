resource "ansible_group" "manager" {
  name = "manager"
  variables = {
    ansible_user = "root"
    ansible_ssh_private_key_file = var.ssh_private_key_file
  }
}

resource "ansible_group" "worker" {
  name = "worker"
  variables = {
    ansible_user = "root"
    ansible_ssh_private_key_file = var.ssh_private_key_file
  }
}

resource "ansible_host" "manager" {
  count = var.number_of_managers
  name = join("", [var.manager_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.manager.name ]
}

resource "ansible_host" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.worker.name ]
}