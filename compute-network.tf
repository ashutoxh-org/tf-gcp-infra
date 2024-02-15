resource "google_compute_network" "vpc" {
  count                           = var.vpc_count
  name                            = "vpc-${count.index}-${random_string.resource_name.result}"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  count         = var.vpc_count
  name          = "webapp-${count.index}-${random_string.resource_name.result}"
  ip_cidr_range = var.webapp_subnet_cidr_ranges[count.index]
  network       = google_compute_network.vpc[count.index].name
}

resource "google_compute_subnetwork" "db" {
  count         = var.vpc_count
  name          = "db-${count.index}-${random_string.resource_name.result}"
  ip_cidr_range = var.db_subnet_cidr_ranges[count.index]
  network       = google_compute_network.vpc[count.index].name
}

resource "google_compute_route" "webapp_route" {
  count            = var.vpc_count
  name             = "route-${count.index}-${random_string.resource_name.result}"
  dest_range       = var.egress_cidr_blocks[0]
  network          = google_compute_network.vpc[count.index].name
  next_hop_gateway = var.default_internet_gateway
}
