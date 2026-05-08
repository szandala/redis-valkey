resource "google_dns_managed_zone" "cache" {
  name        = "cache-internal-vizard-dns"
  dns_name    = var.dns_domain
  description = "Private DNS for caches"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.cache.id
    }
  }
}


resource "google_dns_record_set" "redis_nodes" {
  count = 6

  managed_zone = google_dns_managed_zone.cache.name
  name         = "redis-${count.index + 1}.${var.dns_domain}"
  type         = "A"
  ttl          = 10

  rrdatas = [google_compute_instance.redis[count.index].network_interface[0].network_ip]
}

resource "google_dns_record_set" "valkey_nodes" {
  count = 6

  managed_zone = google_dns_managed_zone.cache.name
  name         = "valkey-${count.index + 1}.${var.dns_domain}"
  type         = "A"
  ttl          = 10

  rrdatas = [google_compute_instance.valkey[count.index].network_interface[0].network_ip]
}

resource "google_dns_record_set" "cache_service_4_apps" {
  # Main DNS cofiguration used by the apps
  # We will be changing it using gcloud
  managed_zone = google_dns_managed_zone.cache.name
  name         = "cache.${var.dns_domain}"
  type         = "A"
  ttl          = 10

  # swap after migration
  rrdatas = [
    google_compute_instance.redis[0].network_interface[0].network_ip,
    google_compute_instance.redis[1].network_interface[0].network_ip,
    google_compute_instance.redis[2].network_interface[0].network_ip,
  ]
  # rrdatas = [
  #   google_compute_instance.valkey[0].network_interface[0].network_ip,
  #   google_compute_instance.valkey[1].network_interface[0].network_ip,
  #   google_compute_instance.valkey[2].network_interface[0].network_ip,
  # ]
}
