provider "google" {
  project     = "elegant-azimuth-393211"
  region      = "europe-central2"
  credentials = file("/var/lib/jenkins/terraform/elegant-azimuth-393211-3a6736bb478a.json")
}

terraform {
  backend "gcs" {
    bucket = "bucket-pro"
    prefix = "terraform/state"
  }
}

resource "google_container_cluster" "gke_cluster" {
  name     = "cluster-1093"
  location = "europe-central2-a"
  initial_node_count = 1

  node_config {
    machine_type   = "n1-standard-1"
    disk_size_gb   = 50
    disk_type      = "pd-balanced"
  }
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
  sensitive = true
}

resource "google_compute_firewall" "allow_inbound" {
  name    = "allow-inbound"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "5000", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_outbound" {
  name    = "allow-outbound"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["0.0.0.0/0"]
}
