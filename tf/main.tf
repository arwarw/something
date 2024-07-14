provider "google" {
	credentials = file(var.gcp_credentials_file)
	project = var.gcp_project
	region = var.gcp_region
	zone = var.gcp_zone
}

resource "google_project_service" "iam" {
	service = "iam.googleapis.com"
	disable_on_destroy = false
}

resource "google_project_service" "compute" {
	service = "compute.googleapis.com" 
	disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
	service = "oslogin.googleapis.com" 
	disable_on_destroy = false
}

resource "google_compute_instance" "vm" {
	name = "vm-${count.index}"
	machine_type = "e2.micro" # free for a month in free tier, sufficient for ademo
	
	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
		}
	}

	network_interface {
		access_config {}
	}
}

output "ip" {
	value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}
