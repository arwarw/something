provider "google" {
	credentials = file(var.gcp_credentials_file)
	project = var.gcp_project
	region = var.gcp_region
	zone = var.gcp_zone
}

resource "google_project_service" "services" {
	for_each = toset(var.gcp_services)
	service = each.value
	disable_on_destroy = false
}

resource "local_file" "ansible_gcp_inventory_config" {
	# write the config file for the ansible GCP automatic inventory
        content = yamlencode({
                plugin = "gcp_compute"
                projects = [var.gcp_project]
                zone = var.gcp_zone
                region = var.gcp_region
                auth_kind = "serviceaccount"
		service_account_file = var.gcp_credentials_file
                filters = []
		hostnames = ["name"]
		compose = {ansible_host = "networkInterfaces[0].accessConfigs[0].natIP"}
                # a gcp label "foo=bar" will become an ansible group "gcp_foo_bar"
                keyed_groups = [{
                        prefix = "gcp"
                        key = "labels"
                }]
        })
        filename = "../ansible/inventory/00-gcp-dynamic.gcp.yml"
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

resource "google_compute_subnetwork" "internal-subnetwork" {
	name = "internal-subnetwork"
	ip_cidr_range = "10.200.16.96/29"
	region = var.gcp_region
	network = google_compute_network.internal-network.id
}

resource "google_compute_network" "internal-network" {
	name = "internal-network"
	auto_create_subnetworks = false
	delete_default_routes_on_create = true	# no routes to anywhere
}

resource "google_compute_firewall" "default-allow" {
	name = "default-allow"
	# firewall rules for the default (external NATed) network
	network = "default"

	priority = 1000

	allow {
		protocol = "icmp"
	}

	allow {
		protocol = "tcp"
		ports = ["22", "80", "443"]
	}

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default-deny" {
	name = "default-deny"
	# firewall rules for the default (external NATed) network
	network = "default"

	# deny is lower prio than allow, to restrict what hasn't been allowed yet.
	priority = 2000

	# deny all that hasn't been explicitly allowed. this is necessary also because there are some implicit allow rules at priority=65535.
	deny { protocol = "all" }

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal-network-allow" {
	name = "internal-network-allow"
	network = google_compute_network.internal-network.name

	priority = 1000

	allow {
		protocol = "icmp"
	}

	allow {
		protocol = "tcp"
		ports = ["9000"]
	}

	source_ranges = ["10.200.16.96/29"]
}

resource "google_compute_firewall" "internal-network-deny" {
	name = "internal-network-deny"
	network = google_compute_network.internal-network.name

	priority = 2000

	deny { protocol = "all" }

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm" {
	name = "vm"
	machine_type = "e2-micro" # free for a month in free tier, sufficient for a demo

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

	network_interface {
		subnetwork = "internal-subnetwork"
		network_ip = "10.200.16.99"
	}

	provisioner "local-exec" {
		# command = "cd ../ansible ; ansible-playbook site.yml"
		command = "echo hallo!!"
	}
}

resource "google_compute_instance" "device9000vm" {
	name = "device9000vm"
	machine_type = "e2-micro" # free for a month in free tier, sufficient for a demo

	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
		}
	}

	network_interface {
		subnetwork = "internal-subnetwork"
		network_ip = "10.200.16.100"
	}

	metadata_startup_script = "hexdump -C /dev/urandom | nc -k -l 9000" # make the device do something interesting on port 9000
}

output "ip" {
	value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}
