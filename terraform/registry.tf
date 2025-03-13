# Enable Container Registry API
resource "google_project_service" "container_registry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"

  disable_on_destroy = false
}

# Enable Artifact Registry API (newer alternative to Container Registry)
resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

# Create Artifact Registry repository
resource "google_artifact_registry_repository" "meetup_ai" {
  provider = google-beta
  
  project       = var.project_id
  location      = var.region
  repository_id = "meetup_ai"
  description   = "Docker repository for ML Platform images"
  format        = "DOCKER"

  # Wait for the API to be enabled
  depends_on = [
    google_project_service.artifact_registry
  ]
}

# Grant permissions to your GKE service account to read from the registry
resource "google_artifact_registry_repository_iam_member" "gke_reader" {
  provider = google-beta
  
  location   = google_artifact_registry_repository.meetup_ai.location
  repository = google_artifact_registry_repository.meetup_ai.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.project_id}.svc.id.goog[kube-system/default]"

  depends_on = [
    google_artifact_registry_repository.meetup_ai,
  ]
}

# Output the registry URL for use in your pipeline
output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.meetup_ai.repository_id}"
  description = "URL of the Artifact Registry repository"
}