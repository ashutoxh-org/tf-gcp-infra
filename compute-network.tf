resource "google_compute_network" "vpc" {
  name                            = "vpc-${random_string.resource_name.result}"
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp-${random_string.resource_name.result}"
  ip_cidr_range = var.webapp_subnet_cidr_range
  region        = var.deployment_region
  network       = google_compute_network.vpc.name
  depends_on    = [google_compute_network.vpc]
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
  provider                = google-beta
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

# TODO: DELETE ME
resource "google_compute_firewall" "allow_ssh_traffic_webapp" {
  name    = "allow-ssh-traffic-webapp-${random_string.resource_name.result}"
  network = google_compute_network.vpc.name
  allow {
    protocol = var.protocol
    ports    = ["22"]
  }
  priority      = 999
  source_ranges = var.source_ranges
  # Only affect traffic to or from instances that have one or more of the specified tags
  target_tags = ["webapp-firewall-ssh"]
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

resource "google_sql_database_instance" "db_instance" {
  name             = "db-instance-${random_string.resource_name.result}"
  region           = var.deployment_region
  database_version = var.database_version
  settings {
    tier              = var.database_tier
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type
    availability_type = var.availability_type
    ip_configuration {
      ipv4_enabled    = false # Disable public IP
      private_network = google_compute_network.vpc.self_link
    }
    backup_configuration {
      enabled = true
    }
  }
  deletion_protection = false
  depends_on          = [google_compute_subnetwork.db_subnet, google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "cloud_native_app_db" {
  name       = "cloud-native-app-db-${random_string.resource_name.result}"
  instance   = google_sql_database_instance.db_instance.name
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "webapp_user" {
  name       = var.db_user
  instance   = google_sql_database_instance.db_instance.name
  password   = random_password.db_password.result
}

resource "google_compute_instance" "webapp_instance" {
  name           = "webapp-instance-${random_string.resource_name.result}"
  machine_type   = var.machine_type
  zone           = var.deployment_zone
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = var.custom_image
      size  = var.webapp_disk_size
      type  = var.webapp_disk_type
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
    access_config {
      // This block assigns a random external IP
    }
  }
  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }
  metadata = {
    db-host = google_sql_database_instance.db_instance.private_ip_address
    db-name = google_sql_database.cloud_native_app_db.name
    db-user = google_sql_user.webapp_user.name
    db-pass = random_password.db_password.result
  }
  metadata_startup_script = <<-EOT
  #!/bin/bash
  set -e
  echo "Error on line $LINENO. Command exited with status $?" >> /var/log/startup-script.log

  # Define the error handling function
  errorHandler() {
    echo "Error on line $LINENO. Command exited with status $?" >> /var/log/startup-script.log
  }

  # Set trap to call errorHandler on any errors
  trap errorHandler ERR

  if which curl >/dev/null; then
    echo "curl exists on this system." >> /var/log/startup-script.log
  else
    echo "curl does not exist on this system." >> /var/log/startup-script.log
  fi

  # Fetch database connection details from metadata service
  DB_HOST=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-host -H "Metadata-Flavor: Google")
  echo "DB_HOST $DB_HOST" >> /var/log/startup-script.log
  DB_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-name -H "Metadata-Flavor: Google")
  echo "DB_NAME $DB_NAME" >> /var/log/startup-script.log
  DB_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-user -H "Metadata-Flavor: Google")
  echo "DB_USER $DB_USER" >> /var/log/startup-script.log
  DB_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-pass -H "Metadata-Flavor: Google")
  echo "DB_PASS $DB_PASS" >> /var/log/startup-script.log

  echo "Fetched DB details" >> /var/log/startup-script.log

  cat <<EOF > /etc/webapp.env
  ENV_DATABASE_URL=jdbc:postgresql://$DB_HOST/$DB_NAME
  ENV_DATABASE_USER=$DB_USER
  ENV_DATABASE_PASSWORD=$DB_PASS
  EOF
  echo "Created env file" >> /var/log/startup-script.log

  # Example of explicitly checking a command's success
  if ! systemctl restart webapp.service; then
    echo "Failed to restart webapp.service" >> /var/log/startup-script.log
  fi

  echo "Script execution completed" >> /var/log/startup-script.log

  # Your script's commands here
  echo "Script finished" >> /var/log/startup-script.log

EOT

  tags       = [var.webapp_firewall_http_tag, var.webapp_firewall_https_tag, var.webapp_firewall_app_tag, "webapp-firewall-ssh"]
  depends_on = [google_compute_subnetwork.webapp_subnet, google_sql_database_instance.db_instance]
}

output "webapp_instance_ip" {
  value      = google_compute_instance.webapp_instance.network_interface[0].access_config[0].nat_ip
  depends_on = [google_compute_instance.webapp_instance]
}