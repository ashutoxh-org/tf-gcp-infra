resource "google_service_account" "webapp_service_account" {
  account_id   = "vm-service-account-${random_string.resource_name.result}"
  display_name = "VM Service Account"
}

resource "google_project_iam_binding" "logging_admin" {
  role       = "roles/logging.admin"
  members    = ["serviceAccount:${google_service_account.webapp_service_account.email}"]
  project    = var.project_id
  depends_on = [google_service_account.webapp_service_account]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  role       = "roles/monitoring.metricWriter"
  members    = ["serviceAccount:${google_service_account.webapp_service_account.email}"]
  project    = var.project_id
  depends_on = [google_service_account.webapp_service_account]
}

resource "google_project_iam_member" "pubsub_invoker_binding_webapp" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
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
    email  = google_service_account.webapp_service_account.email
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

  echo 'Setting UTC timezone...' && sudo timedatectl set-timezone UTC

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
  depends_on = [google_compute_subnetwork.webapp_subnet, google_sql_database_instance.db_instance, google_service_account.webapp_service_account, google_pubsub_topic.verify_email_topic, google_pubsub_subscription.verify_email_subscription, google_cloudfunctions2_function.email_verification_function]
}