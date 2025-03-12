variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
  # Read from TF_VAR_project_id environment variable, with no default
  # This will force the user to set it or provide it via command line
}

variable "region" {
  description = "The region where the GKE cluster will be deployed"
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The zone where the GKE cluster will be deployed"
  type        = string
  default     = "europe-west4-a"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "ai-platform-cluster"
}

variable "node_count" {
  description = "The number of nodes in the GKE cluster"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "The machine type for the GKE nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "gpu_type" {
  description = "The type of GPU to use in the GKE node pool"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count" {
  description = "The number of GPUs to allocate per node"
  type        = number
  default     = 1
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the GKE cluster"
  type        = string
  default     = "1.32"
}

variable "network" {
  description = "The VPC network to use for the GKE cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to use for the GKE cluster"
  type        = string
  default     = "default"
}

variable "enable_private_nodes" {
  description = "Whether to enable private nodes"
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for the cluster"
  type        = bool
  default     = true
}

variable "node_pool_name" {
  description = "Name for the GPU node pool"
  type        = string
  default     = "gpu-pool"
}