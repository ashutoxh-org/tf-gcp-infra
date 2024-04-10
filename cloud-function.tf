resource "google_storage_bucket" "email_verification_function_bucket" {
  name                        = "email-verification-function-bucket-${random_string.resource_name.result}"
  location                    = var.deployment_region
  force_destroy               = true # Allows the bucket to be destroyed even if it contains objects.
  uniform_bucket_level_access = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_key.id
  }
  depends_on = [google_kms_crypto_key_iam_binding.gcs_binding]
}

resource "google_storage_bucket_object" "function_source_archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.email_verification_function_bucket.name
  source = "/Users/ashutosh/Documents/NEU/SEM2/Cloud/function-source.zip"
}

resource "google_vpc_access_connector" "function_to_vpc_connector" {
  name          = "fn-to-vpc-conn-${random_string.resource_name.result}"
  region        = var.deployment_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.function_to_vpc_connector_subnet_cidr_range
}

resource "google_cloudfunctions2_function" "email_verification_function" {
  name        = "email-verification-function-${random_string.resource_name.result}"
  description = "Email Verification Cloud Function"
  location    = var.deployment_region
  build_config {
    runtime     = "java21"
    entry_point = "gcfv2pubsub.PubSubFunction" # Set the entry point
    source {
      storage_source {
        bucket = google_storage_bucket.email_verification_function_bucket.name
        object = google_storage_bucket_object.function_source_archive.name
      }
    }
  }
  service_config {
    max_instance_count    = 1
    available_memory      = "256Mi"
    timeout_seconds       = 60
    vpc_connector         = google_vpc_access_connector.function_to_vpc_connector.id
    service_account_email = google_service_account.cloud_function_service_account.email
    environment_variables = {
      MAILGUN_TOKEN          = var.mailgun_token
      EXPIRY_TIME_IN_MINUTES = var.expiry_time_in_minutes
      DB_HOST                = google_sql_database_instance.db_instance.ip_address[0].ip_address
      DB_NAME                = google_sql_database.cloud_native_app_db.name
      DB_USER                = google_sql_user.webapp_user.name
      DB_PASS                = google_sql_user.webapp_user.password
    }
  }
  event_trigger {
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email_topic.id
    trigger_region = var.deployment_region
  }
}