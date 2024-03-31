resource "google_pubsub_topic" "verify_email_topic" {
  name                       = "verify_email"
  message_retention_duration = "604800s" # 7 days in seconds
  message_storage_policy {
    allowed_persistence_regions = [var.deployment_region]
  }
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name                 = "verify_email_subscription"
  topic                = google_pubsub_topic.verify_email_topic.name
  ack_deadline_seconds = 60
}