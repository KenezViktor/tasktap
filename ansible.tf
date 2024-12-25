resource "ansible_group" "controller" {
  name = "controller"
  variables = {
    ansible_user = "root"
  }
}

resource "ansible_group" "worker" {
  name = "worker"
  variables = {
    ansible_user = "root"
  }
}

resource "ansible_host" "controller" {
  count = var.number_of_controllers
  name = join("", [var.controller_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.controller.name ]
}

resource "ansible_host" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.worker.name ]
}