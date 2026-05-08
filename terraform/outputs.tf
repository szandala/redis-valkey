output "redis_nodes" {
  description = "Node'y Redisa z IP, DNS i rolą"
  value = [
    for i, n in local.redis_nodes : {
      name = n.name
      ip   = google_compute_instance.redis[i].network_interface[0].network_ip
      dns  = "${n.name}.${trimsuffix(var.dns_domain, ".")}"
      zone = n.zone
    }
  ]
}

output "valkey_nodes" {
  description = "Node'y Valkey z IP, DNS i rolą"
  value = [
    for i, n in local.valkey_nodes : {
      name = n.name
      ip   = google_compute_instance.valkey[i].network_interface[0].network_ip
      dns  = "${n.name}.${trimsuffix(var.dns_domain, ".")}"
      zone = n.zone
    }
  ]
}

output "riot_vm" {
  description = "IP i nazwa VM migratora"
  value = {
    name = google_compute_instance.riot.name
    ip   = google_compute_instance.riot.network_interface[0].network_ip
    zone = google_compute_instance.riot.zone
  }
}
