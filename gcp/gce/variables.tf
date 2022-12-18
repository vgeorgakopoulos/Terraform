variable "gcp_project_id" {
    type = string
    description = "Make sure to change the default value to match your current GCP project!"
    default = "terraform-372011"
}

variable "region"{
    type = string
    default = "us-central1"
}

variable "zone" {
    type = string
    default = "us-central1-c"
}