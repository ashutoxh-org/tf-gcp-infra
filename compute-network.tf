resource "google_compute_network" "vpc" {
  name                            = "vpc-${random_string.resource_name.result}"
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = "webapp-${random_string.resource_name.result}"
  ip_cidr_range            = var.webapp_subnet_cidr_range
  region                   = var.deployment_region
  network                  = google_compute_network.vpc.name
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc]
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = "db-${random_string.resource_name.result}"
  ip_cidr_range            = var.db_subnet_cidr_range
  region                   = var.deployment_region
  network                  = google_compute_network.vpc.name
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc]
}

resource "google_compute_global_address" "private_services_access" {
  name          = "private-service-access-${random_string.resource_name.result}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  depends_on    = [google_compute_network.vpc]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta #https://github.com/hashicorp/terraform-provider-google/issues/16275
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_access.name]
  depends_on              = [google_compute_network.vpc]
}

resource "google_compute_route" "webapp_route" {
  name             = "route-${random_string.resource_name.result}"
  dest_range       = var.internet_access_route
  network          = google_compute_network.vpc.name
  next_hop_gateway = var.default_internet_gateway
  depends_on       = [google_compute_network.vpc]
}

resource "google_compute_firewall" "deny_all" {
  name    = "deny-all-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  deny {
    protocol = "all"
  }
  source_ranges = var.source_ranges
  priority      = 1000
  depends_on    = [google_compute_network.vpc]
}

resource "google_compute_firewall" "allow_http_traffic_webapp" {
  name    = "allow-http-traffic-webapp-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  allow {
    protocol = var.protocol
    ports    = var.http_port
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only affect traffic to or from instances that have one or more of the specified tags
  target_tags = [var.webapp_firewall_http_tag]
  depends_on  = [google_compute_network.vpc]
}

resource "google_compute_firewall" "allow_https_traffic_webapp" {
  name    = "allow-https-traffic-webapp-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  allow {
    protocol = var.protocol
    ports    = var.https_port
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only affect traffic to or from instances that have one or more of the specified tags
  target_tags = [var.webapp_firewall_https_tag]
  depends_on  = [google_compute_network.vpc]
}

resource "google_compute_firewall" "allow_app_traffic_webapp" {
  name    = "allow-app-traffic-webapp-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  allow {
    protocol = var.protocol
    ports    = var.app_port
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only affect traffic to or from instances that have one or more of the specified tags
  target_tags = [var.webapp_firewall_app_tag]
  depends_on  = [google_compute_network.vpc]
}

resource "google_compute_firewall" "deny_http_traffic_db" {
  name    = "deny-http-traffic-db-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  deny {
    protocol = var.protocol
    ports    = var.http_port
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only allow traffic from instances that have one or more of the specified tags
  source_tags = [var.db_firewall_http_tag]
  depends_on  = [google_compute_network.vpc]
}

resource "google_compute_firewall" "deny_https_traffic_db" {
  name    = "deny-https-traffic-db-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  deny {
    protocol = var.protocol
    ports    = var.https_port
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only allow traffic from instances that have one or more of the specified tags
  source_tags = [var.db_firewall_https_tag]
  depends_on  = [google_compute_network.vpc]
}

## TODO: COMMENT ME
#resource "google_compute_firewall" "allow_ssh_traffic_webapp" {
#  name    = "allow-ssh-traffic-webapp-${random_string.resource_name.result}"
#  network = google_compute_network.vpc.name
#  allow {
#    protocol = var.protocol
#    ports    = ["22"]
#  }
#  priority      = 999
#  source_ranges = var.source_ranges
#  # Only affect traffic to or from instances that have one or more of the specified tags
#  target_tags = ["webapp-firewall-ssh"]
#  depends_on  = [google_compute_network.vpc]
#}