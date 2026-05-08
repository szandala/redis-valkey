resource "google_compute_network" "cache" {
  name                    = "cache-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "cache" {
  name          = "cache-main-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.cache.id

  private_ip_google_access = true
}

resource "google_compute_firewall" "cache_internal" {
  name    = "cache-allow-internal"
  network = google_compute_network.cache.name

  allow {
    protocol = "tcp"
    ports    = ["6379", "16379"]
  }

  source_tags = ["cache"]
  target_tags = ["cache"]
}

resource "google_compute_firewall" "cache_from_riot" {
  name    = "cache-allow-riot"
  network = google_compute_network.cache.name

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_tags = ["riot"]
  target_tags = ["cache"]
}

resource "google_compute_firewall" "ssh_iap" {
  # Identity Aware Rroxy
  name    = "cache-allow-ssh-iap"
  network = google_compute_network.cache.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["cache", "riot"]
}

resource "google_compute_router" "cache" {
  name    = "cache-router"
  region  = var.region
  network = google_compute_network.cache.id
}

resource "google_compute_router_nat" "cache" {
  name   = "cache-nat"
  router = google_compute_router.cache.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.cache.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
