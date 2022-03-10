variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_password" {}
variable "ssh_key" {}
variable "php_port" {}

module "docker_install" {
  source = "./modules/docker_install"
  ssh_host     = var.ssh_host
  ssh_user     = var.ssh_user
  ssh_password = var.ssh_password
  ssh_key      = var.ssh_key
}

module "docker_run" {
  source = "./modules/docker_run"
  ssh_host     = var.ssh_host
}

module "docker_php" {
  source         = "./modules/docker_php"
  ssh_host       = var.ssh_host
  ssh_user       = var.ssh_user
  ssh_password   = var.ssh_password
  ssh_key        = var.ssh_key
  php_port = var.php_port
}

output "docker_ip_db2" {
  value = module.docker_php.docker_ip_db2
}

output "docker_ip_formationsk8s" {
  value = module.docker_php.docker_ip_formationsk8s
}

output "docker_volume" {
  value = module.docker_php.docker_volume
}
