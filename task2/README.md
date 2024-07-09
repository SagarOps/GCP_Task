# Setting Up Infrastructure with Terraform

This Terraform project automates the setup of a VPC with subnets, a NAT router, and a Cloud Run service on Google Cloud Platform (GCP).

## Prerequisites
1. Google Cloud Project: Ensure you have a Google Cloud project created where resources will be provisioned.

2. Service Enablement: Before running Terraform, ensure the necessary Google Cloud services are enabled:

- **Compute Engine API**: Required for creating VPC, subnets, and NAT router.

To enable the Compute Engine API, run the following command:

```sh
gcloud services list --enabled --project=<your_project_id>

```

Ensure compute.googleapis.com is enabled. If not, enable it with:

```sh
gcloud services enable compute.googleapis.com --project=<your_project_id>
```

## Terraform Files

1. **main.tf**  
  


The **main.tf** file defines the main infrastructure components to be provisioned:

```sh
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  count       = length(var.subnet_cidrs)
  name        = "${var.vpc_name}-subnet-${count.index}"
  ip_cidr_range = element(var.subnet_cidrs, count.index)
  region      = var.region
  network     = google_compute_network.vpc_network.self_link
}

resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-nat-router"
  network = google_compute_network.vpc_network.name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_cloud_run_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.cloud_run_image
        resources {
          limits = {
            memory = var.cloud_run_memory
          }
        }
      }
    }
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = var.project_id
  service  = google_cloud_run_service.default.name

  policy_data = <<EOF
{
  "bindings": [
    {
      "role": "roles/run.invoker",
      "members": [
        "allUsers"
      ]
    }
  ]
}
EOF
}
```

2. **variables.tf**  
  


The variables.tf file defines input variables used in main.tf:

```sh
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
}

variable "cloud_run_memory" {
  description = "The memory allocation for the Cloud Run service."
  type        = string
  default     = "512Mi"
}

```

3. **outputs.tf**
  

The outputs.tf file defines output values to display after Terraform applies changes:

```sh
output "vpc_network_name" {
  description = "The name of the VPC."
  value       = google_compute_network.vpc_network.name
}

output "subnet_names" {
  description = "The names of the subnets."
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.name]
}

output "cloud_run_service_url" {
  description = "The URL of the Cloud Run service."
  value       = google_cloud_run_service.default.status[0].url
}

```

4. **terraform.tfvars (or terraform.auto.tfvars)**
  

Create a file named terraform.tfvars or terraform.auto.tfvars to specify variable values:

```sh
project_id = "your_project_id"
region = "us-central1"
vpc_name = "custom-vpc"
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
cloud_run_service_name = "my-cloud-run-service"
cloud_run_image = "us-central1-docker.pkg.dev/your_project_id/my-repo/hello-world:v1"
cloud_run_memory = "512Mi"
```

## Usage

1. **Clone the Repository:**
  

```sh
git clone <repository_url>
cd task2
```

2. **Initialize Terraform:**
  

Initialize Terraform and download providers:

```sh
terraform init
```

3. **Review and Apply Changes:**
  

Review the execution plan and apply the Terraform configuration:

```sh
terraform plan
terraform apply
```

4. **Verify Output:**
  

After successful deployment, Terraform will output the following information:

- **vpc_network_name**: Name of the created VPC.
- **subnet_names: Names** of the created subnets.
- **cloud_run_service_url**: URL of the deployed Cloud Run service.

5. **Verify Cloud Run Service:**
  

You can verify the status and access the URL of the Cloud Run service using the following command:

```sh
gcloud run services describe ${var.cloud_run_service_name} --region ${var.region} --format "value(status.url)"

```

- You can also check if the project is running by visiting: https://my-cloud-run-service-dtn65ykysq-uc.a.run.app/

6. **Accessing Cloud Run Service:**    

  

By default, the Cloud Run service allows public access (**allUsers**). Adjust IAM policies (**google_cloud_run_service_iam_policy**) if stricter access controls are needed.

7. **Clean Up:**  

  

To avoid unnecessary charges, destroy the created resources:
  
```sh
terraform destroy
```  
  
This README.md provides a detailed step-by-step guide to setting up your infrastructure using Terraform on Google Cloud Platform, including file structure, variable definitions, verifying the Cloud Run service status, and accessing its URL. Adjust the variables and steps according to your project requirements.


