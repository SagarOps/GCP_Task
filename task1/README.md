# Cloud Run Deployment with Terraform

## Overview

This project demonstrates how to deploy a simple "Hello World" application to Google Cloud Run using Terraform.

## Prerequisites

- Google Cloud SDK installed and configured
- Docker installed

## Setup

1. **Create a new GCP project and enable required APIs:**
   - Cloud Run API
   - Cloud Build API
   - Artifact Registry API

2. **Configure Docker to use gcloud for authentication:**
   ```sh
   gcloud auth configure-docker
   ```

3. **Build and push the Docker image:**
- Create the Dockerfile and main.py files:
```sh
# Dockerfile
FROM python:3.8-slim

WORKDIR /app

COPY main.py .

RUN pip install Flask

CMD ["python", "main.py"]

```
```sh
# main.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

```
- Build the Docker image:
```sh
docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo/hello-world:v1 .
```
- Push the Docker image to Google Artifact Registry:
```sh
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo/hello-world:v1
```

4. **Deploy the Cloud Run service using Terraform:**
- Create the main.tf file with the following content:
```sh
provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "us-central1"
}

resource "google_cloud_run_service" "service" {
  name     = "hello-world"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo/hello-world:v1"

        resources {
          limits = {
            memory = "256Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "noauth" {
  service  = google_cloud_run_service.service.name
  location = google_cloud_run_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```
- Initialize Terraform
```sh
terraform init
```

- Apply the Terraform configuration:
```sh
terraform apply
```
- Review the plan and type yes to confirm.

5. **Get the URL of the deployedservice:**
  
  
```sh
gcloud run services describe hello-world --region us-central1 --format "value(status.url)"

```

- You can also check if the project is running by visiting: https://hello-world-dtn65ykysq-uc.a.run.app/


## **Notes**
- Ensure the YOUR_PROJECT_ID placeholder is replaced with your actual GCP project ID.
- This deployment makes the Cloud Run service publicly accessible.




