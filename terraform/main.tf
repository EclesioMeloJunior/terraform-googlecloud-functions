provider "google" {
	project = var.google_project
	credentials = "../.credentials/slack-app-4274e5c8156c.json"
	region = "us-central1"
	zone = "us-central1-c"
}

resource "google_storage_bucket" "slack_notification_bucket" {
	name = var.cloudfunctions_bucket
}

resource "google_storage_bucket" "secrets_bucket" {
	name = var.secrets_bucket
}

resource "google_storage_bucket_object" "ssl_secrets_object" {
	name = "ssl_secret.json"
	bucket = google_storage_bucket.secrets_bucket.name
	source = "../.credentials/ssl.json"
}

resource "random_string" "build_name" {
	length = 5
	special = true
	override_special = "/@$"
}

resource "google_pubsub_topic" "notification_topic" {
	name = var.pubsub_topic
}
