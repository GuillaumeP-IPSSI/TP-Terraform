resource "null_resource" "ssh_target" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.ssh_host
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.ssh_password} | sudo -S mkdir -p /srv/formationsk8s/",
      "echo ${var.ssh_password} | sudo -S chmod 755 -R /srv/formationsk8s/",
      "sleep 5s"
    ]
  }
}

terraform {
  required_providers {
    docker = {
      source    = "kreuzwerker/docker"
      version   = "2.15.0"
    }
  }
}

provider "docker" {
  host = "tcp://${var.ssh_host}:2375"
}

resource "docker_volume" "db2_data" {
  name        = "db2_data"
  driver      = "local"
  driver_opts = {
    o         = "bind"
    type      = "none"
    device    = "/srv/formationsk8s/"
  }
  depends_on = [ null_resource.ssh_target ]
}

resource "docker_network" "formationsk8s_net" {
  name = "formationsk8s_net"
}

resource "docker_container" "db2" {
  name         = "db2"
  image        = "mysql:5.7"
  restart      = "always"
  network_mode = "formationsk8s_net"
  env = [
    "MYSQL_HOST = formationsk8s",
    "MYSQL_PASSWORD = formationsk8s",
    "MYSQL_USER = formationsk8s",
    "MYSQL_DATABASE = formationsk8s"
  ]
  networks_advanced {
    name = docker_network.formationsk8s_net.name
  }
  volumes {
    host_path      = "/srv/formationsk8s/"
    container_path = "/var/lib/mysql/"
    volume_name    = "db2_data"
  }
}

resource "docker_container" "formationsk8s" {
  name              = "formationsk8s"
  image             = "formationsk8s/tp_php_mysql:latest"
  restart           = "always"
  networks_advanced {
    name = docker_network.formationsk8s_net.name
  }
  env = [
    "MYSQL_DB_HOST = db:3306",
    "MYSQL_DB_PASSWORD = formationsk8s",
    "MYSQL_DB_USER = root",
    "MYSQL_DB_NAME = formationsk8s"
  ]
  ports {
    internal = 80
    external = var.php_port
  }
}
