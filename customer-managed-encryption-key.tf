resource "google_kms_key_ring" "key_ring" {
  provider = google-beta
  name     = "cmek-kry-ring-${random_string.resource_name.result}"
  location = var.deployment_region
}

resource "google_kms_crypto_key" "vm_key" {
  provider        = google-beta
  name            = "vm-key-${random_string.resource_name.result}"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s" # 30 days in seconds
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "sql_key" {
  provider        = google-beta
  name            = "sql-key-${random_string.resource_name.result}"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s" # 30 days in seconds
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "bucket_key" {
  provider        = google-beta
  name            = "bucket-key-${random_string.resource_name.result}"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s" # 30 days in seconds
  lifecycle {
    prevent_destroy = false
  }
}