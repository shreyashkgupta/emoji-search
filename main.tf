

variable "region" {
    type = string
    description = "GCP region to deploy in"
    default = "us-west2"
}

variable "project_id" {
    type = string
    default = ""
    description = "Project ID"
}

variable "instance_name" {
    type = string
    description = "Name of the Instance"
    default = "gcloud-ip-test-2-vm"
}

variable "instance_type" {
    type = string
    description = "Type of VM Instance"
    default = "e2-medium"
}

variable "instance_state" {
    type = string
    description = "Instance state"
    default = "RUNNING"
}

variable "env_file_content" {
    type = string
    description = "Environment file content"
    default = ""
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}


provider "google" {
  region = var.region
  project = var.project_id
}


data "google_compute_zones" "available" {
  region = var.region
}

resource "google_project_service" "compute_service" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}


resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone = data.google_compute_zones.available.names[0]

  desired_status = var.instance_state

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["vm-${var.instance_name}"]

  metadata_startup_script = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install docker.io -y
# sudo usermod -a -G docker ubuntu
sudo service docker start
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
# Get git repo
cd /home/ubuntu
pwd
sudo git clone https://github.com/shreyashkgupta/emoji-search.git code_files
cd /home/ubuntu/code_files
sudo sh -c echo "${var.env_file_content}" > .env

# Pull and run your Docker image
sudo docker-compose -f docker-compose.yml build
sudo docker-compose -f docker-compose.yml up -d

  EOF
}

resource "google_compute_firewall" "default" {
  name    = "allow-all-${var.instance_name}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vm-${var.instance_name}"]
}

