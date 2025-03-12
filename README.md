# GKE GPU Backstage Demo

This project demonstrates how to deploy a Kubernetes cluster on Google Kubernetes Engine (GKE) with GPU access using Terraform. It also showcases self-service capabilities for data scientists through Backstage, allowing them to deploy machine learning models from Hugging Face onto the cluster via Flux.

## Project Structure

```
meetup-ai
├── terraform               # Terraform configuration files for GKE
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Input variables for Terraform
│   ├── outputs.tf          # Outputs of the Terraform deployment
│   ├── gke.tf              # GKE cluster configuration
│   └── providers.tf        # Provider configuration for Google Cloud
├── kubernetes              # Kubernetes manifests and Flux configurations
│   ├── flux-system
│   │   ├── gotk-components.yaml  # Flux components configuration
│   │   └── gotk-sync.yaml        # Flux synchronization configuration
│   └── manifests
│       ├── backstage
│       │   ├── deployment.yaml    # Backstage deployment configuration
│       │   ├── service.yaml       # Backstage service configuration
│       │   └── configmap.yaml     # Backstage configuration map
│       └── ml-models
│           ├── huggingface-deployment.yaml # Hugging Face model deployment
│           └── gpu-resources.yaml          # GPU resource specifications
├── backstage                # Backstage application configuration
│   ├── app-config.yaml      # Backstage application configuration
│   ├── catalog-info.yaml     # Backstage catalog metadata
│   └── templates
│       └── ml-model-template.yaml  # Template for deploying ML models
├── scripts                  # Scripts for setup and deployment
│   ├── setup.sh             # Setup script for initializing the project
│   └── deploy-model.sh      # Script for deploying ML models
└── README.md                # Project documentation
```

## Getting Started

### Prerequisites

- Google Cloud account
- Terraform installed
- kubectl installed
- Flux CLI installed
- Backstage CLI installed

### Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   cd meetup-ai
   ```

2. Configure your Google Cloud credentials and set the necessary environment variables.

`gcloud config set project <project-id>`
`gcloud config set compute/region <region>`
`source .env`
If it is a new project , you might have to enable two APIs:

`gcloud services enable cloudresourcemanager.googleapis.com`
`gcloud services enable iamcredentials.googleapis.com`

Create the terraform service account.
```
gcloud iam service-accounts create terraform-sa \
  --description="Terraform service principal" \
  --display-name="Terraform service account"
```

# Replace YOUR_PROJECT_ID with your actual project ID
`export PROJECT_ID=$(gcloud config get-value project)`

# Grant required roles
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Allow your user account to impersonate the service account
# Get your current user email
export USER_EMAIL=$(gcloud config get-value account)
echo $USER_EMAIL

# Verify it's correct, then grant impersonation rights
gcloud iam service-accounts add-iam-policy-binding \
  terraform-sa@$PROJECT_ID.iam.gserviceaccount.com \
  --member="user:$USER_EMAIL" \
  --role="roles/iam.serviceAccountTokenCreator"

```

```gcloud auth application-default login```

3. Navigate to the `terraform` directory and initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

4. Review and modify the `variables.tf` file to set your project ID, region, and GPU specifications.

5. Apply the Terraform configuration to create the GKE cluster:
   ```
   terraform apply
   ```

6. Once the cluster is up and running, navigate to the `kubernetes/flux-system` directory and apply the Flux configurations:
   ```
   kubectl apply -f gotk-components.yaml
   kubectl apply -f gotk-sync.yaml
   ```

6. Deploy the Backstage application and Hugging Face model using the provided manifests in the `kubernetes/manifests` directory.

### Usage

Data scientists can use the Backstage interface to deploy machine learning models from Hugging Face onto the GKE cluster. The provided templates and scripts facilitate self-service deployments.

### Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

### License

This project is licensed under the MIT License. See the LICENSE file for more information.