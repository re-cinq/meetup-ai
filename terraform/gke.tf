resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone  # Using zone instead of region for GPU compatibility
  
  deletion_protection = false

  # Use the default network
  network    = "default"
  subnetwork = "default"

  # Remove the default node pool since we'll create a separate GPU node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gcp_filestore_csi_driver_config {
      enabled = true  # Enable filestore for better storage options
    }
  }

  # Configure workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Use VPC-native (IP aliasing)
  networking_mode = "VPC_NATIVE"
  
  # Configure IP allocation for pods and services
  ip_allocation_policy {}
}

resource "google_container_node_pool" "gpu_pool" {
  name       = var.node_pool_name
  location   = var.zone  # Using zone instead of region for GPU compatibility
  cluster    = google_container_cluster.primary.name
  
  # Start with just 1 node for testing
  node_count = 1  

  # Auto-scaling for production
  autoscaling {
    min_node_count = 0
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Use accelerator-optimized machine type for GPUs
  node_config {
    machine_type = "n1-standard-4"  # A proven compatible machine type with T4 GPUs
    
    # GPU config - using a common available GPU type
    guest_accelerator {
      type  = var.gpu_type  # Using the variable to make it easy to change
      count = var.gpu_count
      # GPU sharing feature (optional)
    }

    # Make sure we have enough disk space for NVIDIA drivers and models
    disk_size_gb = 100
    disk_type    = "pd-standard"

    # Enable workload identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Add NVIDIA GPU driver install
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
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

    # Set metadata for auto-installing NVIDIA drivers
    metadata = {
      "install-nvidia-driver" = "true"
    }
  }

  # Important: Set a longer timeframe for GPU node creation
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}