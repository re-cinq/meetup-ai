#!/bin/bash

# Set variables
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
CLUSTER_NAME="gke-gpu-cluster"
ZONE="us-central1-a"
NODE_POOL_NAME="gpu-pool"
MACHINE_TYPE="n1-standard-4"
GPU_TYPE="nvidia-tesla-k80"
GPU_COUNT=1

# Authenticate with Google Cloud
gcloud auth login

# Set the project
gcloud config set project $PROJECT_ID

# Create the GKE cluster with GPU support
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --num-nodes 1 \
  --machine-type $MACHINE_TYPE \
  --accelerator type=$GPU_TYPE,count=$GPU_COUNT \
  --enable-ip-alias

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

# Initialize Terraform
cd terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

# Return to the root directory
cd ..