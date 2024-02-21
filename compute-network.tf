resource "google_compute_network" "vpc" {
  name                            = "vpc-${random_string.resource_name.result}"
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp-${random_string.resource_name.result}"
  ip_cidr_range = var.webapp_subnet_cidr_range
  region        = var.deployment_region
  network       = google_compute_network.vpc.name
  depends_on    = [google_compute_network.vpc]
}

resource "google_compute_subnetwork" "db" {
  name          = "db-${random_string.resource_name.result}"
  ip_cidr_range = var.db_subnet_cidr_range
  region        = var.deployment_region
  network       = google_compute_network.vpc.name
  depends_on    = [google_compute_network.vpc]
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

resource "google_compute_instance" "webapp_vm" {
  name           = "webapp-instance-${random_string.resource_name.result}"
  machine_type   = var.machine_type
  zone           = var.deployment_zone
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = var.custom_image
      size  = var.disk_size
      type  = var.disk_type
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp.name
    access_config {
      // This block assigns an external IP
    }
  }
  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }
  tags       = [var.webapp_firewall_http_tag, var.webapp_firewall_https_tag, var.webapp_firewall_app_tag]
  depends_on = [google_compute_network.vpc, google_compute_subnetwork.webapp]
}

output "webapp_instance_ip" {
  value      = google_compute_instance.webapp_vm.network_interface[0].access_config[0].nat_ip
  depends_on = [google_compute_instance.webapp_vm]
}