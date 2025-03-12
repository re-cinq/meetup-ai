# Get impersonated access token for the service account
data "google_service_account_access_token" "default" {
  provider               = google.no_impersonation
  target_service_account = "terraform-sa@${var.project_id}.iam.gserviceaccount.com"
  scopes                 = ["cloud-platform"]
  lifetime               = "3600s"
}

# Main provider that uses the impersonated credentials
provider "google" {
  project      = var.project_id
  region       = var.region
  access_token = data.google_service_account_access_token.default.access_token
}

# Alternate provider without impersonation for bootstrapping
provider "google" {
  alias = "no_impersonation"
  project = var.project_id
  region  = var.region
  # Uses Application Default Credentials without impersonation
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_service_account_access_token.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}