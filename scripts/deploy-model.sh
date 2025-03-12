#!/bin/bash

# Set variables
NAMESPACE="ml-models"
MODEL_NAME="huggingface-model"
FLUX_REPO_URL="https://github.com/your-org/your-repo.git"
FLUX_PATH="./kubernetes/manifests/ml-models"

# Check if Flux is installed
if ! command -v flux &> /dev/null
then
    echo "Flux CLI could not be found. Please install Flux to proceed."
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy the model using Flux
flux create kustomization $MODEL_NAME \
    --source=GitRepository/$FLUX_REPO_URL \
    --path=$FLUX_PATH \
    --namespace=$NAMESPACE \
    --interval=1m

echo "Model deployment initiated for $MODEL_NAME in namespace $NAMESPACE."