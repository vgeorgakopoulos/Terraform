/*
GCE NOTES BEFORE RUNNING THE TERRAFORM SCRIPT

1) Createa a sample Service Account responsible for the GCE instaces:
    gcloud iam service-accounts create compute-engine-sa \
    --description="Compute Engine Service Account" \
    --display-name="compute-engine-sa"

    gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member=serviceAccount:compute-engine-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/compute.admin
  
2) Generate credentials for the service account (NOTE: make sure the location for storing the credentials exists!!!)
   gcloud iam service-accounts keys create /tmp/compute-instance.json --iam-account compute-engine-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com
*/


provider "google" {
  credentials = file("/tmp/compute-instance.json")
  project = var.gcp_project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "terraform-subnet" {
  name          = "terraform-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "default" {
  name         = "terrarom-flask-vm"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.terraform-subnet.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

#Allow ssh to the GCE instance
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
