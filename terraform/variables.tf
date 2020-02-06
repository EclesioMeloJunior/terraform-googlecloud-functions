variable "cloudfunctions_bucket" {
  default = "slack-app-bucket"
}

variable "secrets_bucket" {
  default = "secrets_app_bucket"
}

variable "pubsub_topic" {
  default = "NOTIFY_SLACK"
}

variable "google_project" {
  default = "slack-app-265014"
}

variable "google_project_credentials" {
  default = "../.credentials/slack-app-4274e5c8156c.json"
}

