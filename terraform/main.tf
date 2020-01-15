provider "google" {
	project = var.google_project
	credentials = "../.credentials/slack-app-4274e5c8156c.json"
	region = "us-central1"
	zone = "us-central1-c"
}

resource "google_storage_bucket" "slack_notification_bucket" {
	name = var.cloudfunctions_bucket
}

data "archive_file" "slack_notification_zip" {
	type = "zip"
	source_dir = "../app/"
	output_path = "../builds/${random_string.build_name.result}-app.zip"
}

data "archive_file" "sidecar_app_zip" {
	type = "zip"
	source_dir = "../sidecar_app/"
	output_path = "../builds/${random_string.build_name.result}-sidecar_app.zip"
}

resource "google_storage_bucket_object" "slack_notification_object" {
	name = "${random_string.build_name.result}.${data.archive_file.slack_notification_zip.output_md5}.zip"
	bucket = google_storage_bucket.slack_notification_bucket.name
	source = "../builds/${random_string.build_name.result}-app.zip"
}

resource "google_storage_bucket_object" "sidecar_app_object" {
	name = "${random_string.build_name.result}.${data.archive_file.sidecar_app_zip.output_md5}.zip"
	bucket = google_storage_bucket.slack_notification_bucket.name
	source = "../builds/${random_string.build_name.result}-sidecar_app.zip"
}

resource "google_cloudfunctions_function" "sidecar_app_function" {
	runtime = "nodejs10"
	entry_point = "app"
	available_memory_mb = 128
	project = var.google_project
	name = "sidecar_app"
	source_archive_bucket = google_storage_bucket.slack_notification_bucket.name
	source_archive_object = google_storage_bucket_object.sidecar_app_object.name
	event_trigger {
		event_type = "google.pubsub.topic.publish"
		resource = var.pubsub_topic
	}
}

resource "google_cloudfunctions_function" "slack_notification_function" {
	runtime = "nodejs10"
	entry_point = "app"
	available_memory_mb = 128
	project = var.google_project 
	name = "slack-app-notification"
	source_archive_bucket = google_storage_bucket.slack_notification_bucket.name
	source_archive_object = google_storage_bucket_object.slack_notification_object.name

	event_trigger {
		event_type = "google.pubsub.topic.publish"
		resource = var.pubsub_topic
	}
} 

resource "random_string" "build_name" {
	length = 5
	special = true
	override_special = "/@$"
}

resource "google_pubsub_topic" "notification_topic" {
	name = var.pubsub_topic
}
