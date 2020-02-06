resource "cloudfunc_packer" "sidecar_app" {
  function_path = "../sidecar_app"
  output        = "sidecar_app"
}

resource "google_storage_bucket_object" "sidecar_app_object" {
  name   = "${random_string.build_name.result}.sidecar_app.zip"
  bucket = google_storage_bucket.supermarket_bucket.name
  source = cloudfunc_packer.sidecar_app.id
}

resource "google_cloudfunctions_function" "sidecar_app_function" {
  runtime               = "nodejs8"
  entry_point           = "app"
  name                  = "sidecar-app"
  project               = var.google_project
  available_memory_mb   = 128
  source_archive_object = google_storage_bucket_object.sidecar_app_object.name
  source_archive_bucket = google_storage_bucket.supermarket_bucket.name
  event_trigger {
    resource   = var.pubsub_topic
    event_type = "google.pubsub.topic.publish"
  }

  environment_variables = {
    SSL_FILE = google_storage_bucket_object.ssl_secrets_object.self_link
    BUCKET   = var.secrets_bucket
  }
}
