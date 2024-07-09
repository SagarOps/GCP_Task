variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region in which to provision resources."
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "custom-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "A list of CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "my-cloud-run-service"
}

variable "cloud_run_image" {
  description = "The container image for the Cloud Run service."
  type        = string
  default     = "us-central1-docker.pkg.dev/elite-academy-428817-h0/my-repo/hello-world:v1"
}

variable "cloud_run_memory" {
  description = "The memory allocation for the Cloud Run service."
  type        = string
  default     = "512Mi"
}
