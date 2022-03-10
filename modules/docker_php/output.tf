output "docker_ip_db2" {
  value = docker_container.db2.ip_address
}

output "docker_ip_formationsk8s" {
  value = docker_container.formationsk8s.ip_address
}

output "docker_volume" {
  value = docker_volume.db2_data.driver_opts.device
}
