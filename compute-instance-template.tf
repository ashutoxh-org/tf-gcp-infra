resource "google_compute_instance_template" "webapp_instance_template" {
  name_prefix  = "webapp-instance-template-${random_string.resource_name.result}"
  machine_type = var.machine_type
  can_ip_forward = true
  disk {
    boot         = true
    auto_delete  = true
    source_image = var.custom_image
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

    # Fetch database connection details from metadata service
    DB_HOST=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-host -H "Metadata-Flavor: Google")
    DB_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-name -H "Metadata-Flavor: Google")
    DB_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-user -H "Metadata-Flavor: Google")
    DB_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-pass -H "Metadata-Flavor: Google")
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

