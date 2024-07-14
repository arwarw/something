variable "gcp_credentials_file" {
	type = string
	description = "GCP credentials file (~/.gcloud/something-...json usually)"
}

variable "gcp_project" {
	type = string
	description = "GCP project ID"
}

variable "gcp_region" {
	type = string
	description = "GCP region"
	default = "us-east1" # closest in free tier
}

variable "gcp_zone" {
	type = string
	description = "GCP zone"
	default = "us-east1-d" # closest in free tier
}
