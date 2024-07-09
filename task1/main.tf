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
