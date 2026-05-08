resource "google_compute_instance" "riot" {
  name         = "riot-migrator"
  machine_type = var.riot_machine_type
  zone         = var.zones[0]
  tags         = ["riot"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.riot_disk_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cache.id
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/bootstrap-riot.sh.tftpl", {
    SOURCE_REDIS  = google_compute_instance.redis[0].network_interface[0].network_ip
    TARGET_VALKEY = google_compute_instance.valkey[0].network_interface[0].network_ip
    REDIS_PASS    = var.redis_password
    VALKEY_PASS   = var.valkey_password
  })

  service_account {
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
