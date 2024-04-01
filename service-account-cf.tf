resource "google_service_account" "cloud_function_service_account" {
  account_id   = "cf-pubsub-invoker"
  display_name = "Cloud Function Pub/Sub Invoker"
}

resource "google_project_iam_member" "pubsub_invoker_binding_cf" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.cloud_function_service_account.email}"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_function_service_account.email}"
}

resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.cloud_function_service_account.email}"
}