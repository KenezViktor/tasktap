resource "libvirt_network" "docker-swarm" {
  name = "docker-swarm"
  mode = "nat"

  domain = var.domain_name
  addresses = [ join("" ,[var.network.network, var.network.netmask]) ]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    
    hosts {
      hostname = "tasktap.local"
      ip = "10.0.40.100"
    }

    hosts {
      hostname = "phpmyadmin.local"
      ip = "10.0.40.100"
    }
  }
}