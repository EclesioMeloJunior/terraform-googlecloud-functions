data "template_file" "sidecar_app_index" {
	template = file("../sidecar_app/index.js")
}

data "template_file" "sidecar_app_package_json" {
	template = file("../sidecar_app/package.json")
}

data "archive_file" "sidecar_app_zip" {
	type = "zip"
	output_path = "../builds/${random_string.build_name.result}-sidecar_app.zip"

	source {
		content = data.template_file.sidecar_app_index.rendered
		filename = "index.js"
	}
	
	source {
		content = data.template_file.sidecar_app_package_json.rendered
		filename = "package.json"
	}
}

resource "google_storage_bucket_object" "sidecar_app_object" {
	name = "${random_string.build_name.result}.${data.archive_file.sidecar_app_zip.output_md5}.zip"
	bucket = google_storage_bucket.slack_notification_bucket.name
	source = "../builds/${random_string.build_name.result}-sidecar_app.zip"
}

resource "google_cloudfunctions_function" "sidecar_app_function" {
	runtime = "nodejs10"
	entry_point = "app"
	name = "sidecar-app"
	project = var.google_project
	available_memory_mb = 128
	source_archive_object = google_storage_bucket_object.sidecar_app_object.name
	source_archive_bucket = google_storage_bucket.slack_notification_bucket.name
	event_trigger {
		resource = var.pubsub_topic
		event_type = "google.pubsub.topic.publish"
	}
	
	environment_variables = {
		SSL_FILE = google_storage_bucket_object.ssl_secrets_object.self_link 
		BUCKET = var.secrets_bucket
	}
}
