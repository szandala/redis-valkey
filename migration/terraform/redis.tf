locals {
  #   redis-1 (master, zone-b) ← redis-4 (replica, zone-c)
  #   redis-2 (master, zone-c) ← redis-5 (replica, zone-a)
  #   redis-3 (master, zone-a) ← redis-6 (replica, zone-b)
  redis_nodes = [
    { name = "redis-1", zone = var.zones[0] },
    { name = "redis-2", zone = var.zones[1] },
    { name = "redis-3", zone = var.zones[2] },
    { name = "redis-4", zone = var.zones[1] },
    { name = "redis-5", zone = var.zones[2] },
    { name = "redis-6", zone = var.zones[0] },
  ]
}

resource "google_compute_instance" "redis" {
  count = 6

  name         = local.redis_nodes[count.index].name
  machine_type = var.cache_machine_type
  zone         = local.redis_nodes[count.index].zone
  tags         = ["cache", "redis"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.cache_disk_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cache.id
    # no public IP
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
  # clusters are hard to be configured, they are configured with scripts
  metadata_startup_script = templatefile("${path.module}/scripts/bootstrap-redis.sh.tftpl", {
    REDIS_PASS = var.redis_password
    DNS_NAME   = "${local.redis_nodes[count.index].name}.${var.dns_domain}"
  })

  service_account {
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  depends_on = [google_compute_subnetwork.cache]
}
