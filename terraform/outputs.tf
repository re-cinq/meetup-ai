output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the GKE cluster"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for the GKE cluster"
  value       = <<-EOT
    apiVersion: v1
    kind: Config
    current-context: ${google_container_cluster.primary.name}
    contexts:
    - name: ${google_container_cluster.primary.name}
      context:
        cluster: ${google_container_cluster.primary.name}
        user: ${google_container_cluster.primary.name}
    clusters:
    - name: ${google_container_cluster.primary.name}
      cluster:
        certificate-authority-data: ${google_container_cluster.primary.master_auth[0].cluster_ca_certificate}
        server: https://${google_container_cluster.primary.endpoint}
    users:
    - name: ${google_container_cluster.primary.name}
      user:
        auth-provider:
          name: gcp
    EOT
  sensitive   = true
}

output "kubectl_command" {
  description = "Command to get kubectl credentials for the cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}