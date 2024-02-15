resource "google_compute_network" "vpc" {
  name                    = "vpc-${random_string.resource_name.result}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp-${random_string.resource_name.result}"
  ip_cidr_range = var.webapp-subnet-cidr-range
  region        = var.region
  network       = google_compute_network.vpc.name
}

resource "google_compute_subnetwork" "db" {
  name          = "db-${random_string.resource_name.result}"
  ip_cidr_range = var.db-subnet-cidr-range
  region        = var.region
  network       = google_compute_network.vpc.name
}

resource "google_compute_route" "webapp_route" {
  name       = "route-${random_string.resource_name.result}"
  dest_range = var.webapp-egress
  network    = google_compute_network.vpc.name
  next_hop_gateway = var.internet-gateway
}
