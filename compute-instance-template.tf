resource "google_compute_instance_template" "webapp_instance_template" {
  name_prefix    = "webapp-instance-template-${random_string.resource_name.result}"
  machine_type   = var.machine_type
  region = var.deployment_region
  can_ip_forward = true
  disk {
    boot         = true
    auto_delete  = true
    source_image = var.custom_image
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_key.id
    }
    disk_size_gb = var.webapp_disk_size
    disk_type = var.webapp_disk_type
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
    access_config {}
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
  metadata_startup_script = file("scripts/startup-script.sh")

  tags       = [var.webapp_firewall_http_tag, var.webapp_firewall_https_tag, var.webapp_firewall_app_tag, "webapp-firewall-ssh"]
  depends_on = [google_compute_subnetwork.webapp_subnet, google_sql_database_instance.db_instance, google_service_account.webapp_service_account, google_pubsub_topic.verify_email_topic, google_pubsub_subscription.verify_email_subscription, google_cloudfunctions2_function.email_verification_function]
}

