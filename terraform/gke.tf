resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Remove the default node pool since we'll create a separate GPU node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable Kubernetes Dashboard
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  # Configure private cluster - updated to use Private Service Connect
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false
    # Remove the master_ipv4_cidr_block line - not compatible with PSC
    
    # Add this for Private Service Connect instead
    master_global_access_config {
      enabled = true
    }
  }

  # Enable network policy
  network_policy {
    enabled = true
  }
  
  # Configure workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Use VPC-native (IP aliasing)
  networking_mode = "VPC_NATIVE"
  
  # Configure IP allocation for pods and services
  ip_allocation_policy {
    # Let GKE choose the ranges automatically
  }
}

resource "google_container_node_pool" "gpu_pool" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    # Specify GPU configuration
    guest_accelerator {
      count = var.gpu_count
      type  = var.gpu_type
    }

    # Enable workload identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Additional node configuration
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    
    # Add labels to identify GPU nodes
    labels = {
      "gpu-node" = "true"
    }
    
    # Add taint to ensure only GPU workloads run on these nodes
    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }
  }
  
  # NVIDIA GPU driver installation
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}