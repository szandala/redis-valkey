locals {
  valkey_nodes = [
    { name = "valkey-1", zone = var.zones[0] },
    { name = "valkey-2", zone = var.zones[1] },
    { name = "valkey-3", zone = var.zones[2] },
    { name = "valkey-4", zone = var.zones[1] },
    { name = "valkey-5", zone = var.zones[2] },
    { name = "valkey-6", zone = var.zones[0] },
  ]
}

resource "google_compute_instance" "valkey" {
  count = 6

  name         = local.valkey_nodes[count.index].name
  machine_type = var.cache_machine_type
  zone         = local.valkey_nodes[count.index].zone
  tags         = ["cache", "valkey"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.cache_disk_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cache.id
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/bootstrap-valkey.sh.tftpl", {
    VALKEY_PASS = var.valkey_password
    DNS_NAME    = "${local.valkey_nodes[count.index].name}.${var.dns_domain}"
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
