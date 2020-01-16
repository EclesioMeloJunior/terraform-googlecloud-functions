data "archive_file" "app_zip" {
	type = "zip"
	source_dir = "../app/"
	output_path = "../builds/${random_string.build_name.result}-app.zip"
}

resource "google_storage_bucket_object" "app_object" {
	name = "${random_string.build_name.result}.${data.archive_file.app_zip.output_md5}.zip"
	bucket = google_storage_bucket.slack_notification_bucket.name
	source = "../builds/${random_string.build_name.result}-app.zip"
}

resource "google_cloudfunctions_function" "app_function" {
	runtime = "nodejs10"
	entry_point = "app"
	available_memory_mb = 128
	name = "slack-app-notification"
	source_archive_object = google_storage_bucket_object.app_object.name
	source_archive_bucket = google_storage_bucket.slack_notification_bucket.name
	event_trigger {
		event_type = "google.pubsub.topic.publish"
		resource = var.pubsub_topic
	}
}
