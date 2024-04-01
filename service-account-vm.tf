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