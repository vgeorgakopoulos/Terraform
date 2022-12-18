output "gce_private_ip" {
    description = "Private IP of GCE instance"
    value = google_compute_instance.default.network_interface.0.network_ip
}

output "gce_public_ip" {
    description = "Public IP of GCE instance"
    value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
