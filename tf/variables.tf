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
	default = "us-east1-b" # closest in free tier
}

variable "gcp_services" {
	type = list(string)
	description = "GCP services to enable for project"
	default = [
		"cloudresourcemanager.googleapis.com",
		"iam.googleapis.com",
		"compute.googleapis.com",
		"oslogin.googleapis.com",
	]
}

variable "ssh_pubkey_file" {
	type = string
	description = "ssh pubkey file to authorize for the user and root account on all VMs created in this project"
	default = "~/.ssh/id_rsa.pub"
}

