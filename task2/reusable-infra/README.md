# Reusable Infrastructure Module

This module provisions a VPC, subnets, Cloud NAT, and a Cloud Run service.

## Usage

```hcl
module "reusable_infra" {
  source                 = "../path_to_your_module/reusable-infra"
  project_id             = "your-project-id"
  region                 = "us-central1"
  vpc_name               = "custom-vpc"
  vpc_cidr               = "10.0.0.0/16"
  subnet_cidrs           = ["10.0.1.0/24", "10.0.2.0/24"]
  cloud_run_service_name = "my-cloud-run-service"
  cloud_run_image        = "gcr.io/cloudrun/hello"
  cloud_run_memory       = "512Mi"
}
