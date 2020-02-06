variable "cloudfunctions_bucket" {
  default = "supermarket-bucket"
}

variable "secrets_bucket" {
  default = "supermarket_secrets_app_bucket"
}

variable "pubsub_topic" {
  default = "SUPERMARKET_ON"
}

variable "google_project" {
  default = "supermarket-267415"
}

variable "google_project_credentials" {
  default = "../.credentials/supermarket-admin.json"
}

