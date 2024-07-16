provider "google" {
	credentials = file(var.gcp_credentials_file)
	project = var.gcp_project
	region = var.gcp_region
	zone = var.gcp_zone
}

resource "google_compute_project_metadata" "default" {
	# This simply enables ssh login with an ssh-key for the current
	# local user on all VMs in the project with username 'user' and passwordless
	# sudo to root (default on Ubuntu).
	#
	# This could be improved by using oslogin, but the setup is far more complicated
	# and needs quite some extra steps in the cloud console, so I'll to the simpler
	# thing here.
	metadata = {
		ssh-keys = format("user:%s", file(var.ssh_pubkey_file))
	}
}

resource "google_project_service" "services" {
	for_each = toset(var.gcp_services)
	service = each.value
	disable_on_destroy = false
}

resource "google_compute_instance" "vm" {
	name = "vm"
	machine_type = "e2-micro" # free for a month in free tier, sufficient for ademo

	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
		}
	}

	network_interface {
		network = "default"
		access_config {
			# empty is default public IP
			# the IP address will be output further below.
		}
	}
}

output "ip" {
	value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}
