# GKE GPU Backstage Demo

This project demonstrates how to deploy a Kubernetes cluster on Google Kubernetes Engine (GKE) with GPU access using Terraform. It also showcases self-service capabilities for data scientists through Backstage, allowing them to deploy machine learning models from Hugging Face onto the cluster via Flux.

## Project Structure

```
meetup-ai/
├── .env                             # Environment variables
├── README.md                        # Project documentation
├── terraform/
│   ├── main.tf                      # Main Terraform configuration (delete or empty)
│   ├── variables.tf                 # Define Terraform variables
│   ├── providers.tf                 # Provider configuration
│   ├── gke.tf                       # GKE cluster configuration
│   └── outputs.tf                   # Output values
├── kubernetes/
│   ├── flux-system/
│   │   ├── gotk-components.yaml     # Flux core components
│   │   └── gotk-sync.yaml           # Flux Git repository sync configuration
│   └── manifests/
│       ├── backstage/
│       │   ├── deployment.yaml      # Backstage deployment
│       │   ├── service.yaml         # Backstage service
│       │   └── configmap.yaml       # Backstage configuration
│       └── ml-models/
│           ├── huggingface-deployment.yaml  # Hugging Face model deployment
│           └── gpu-resources.yaml           # GPU resources configuration
|           |__ service.yaml                 # Service
├── backstage/
│   ├── app-config.yaml              # Backstage application configuration
│   ├── catalog-info.yaml            # Backstage catalog metadata
│   └── templates/
│       └── ml-model-template.yaml   # Template for deploying ML models
└── scripts/
    ├── setup.sh                     # Setup script
    └── deploy-model.sh              # Script for deploying ML models
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

`gcloud auth application-default login`

3. Navigate to the `terraform` directory and initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

4. Review and modify the `variables.tf` file to set your project ID, region, and GPU specifications.

5. Apply the Terraform configuration to create the GKE cluster:
   ```
   terraform plan
   terraform apply
   ```

6. Once the cluster is up and running, navigate to the `kubernetes/flux-system` directory and apply the Flux configurations:
`gcloud container clusters get-credentials ai-platform-cluster`

7. Install Flux on the cluster:

# Install Flux CLI
`brew install fluxcd/tap/flux`

# Bootstrap Flux (replace with your Git repository)
```
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --path=kubernetes \
  --personal
```
--- or ----
```
flux bootstrap github \
  --owner=$GITHUB_OWNER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=kubernetes \
  --token-auth
```
1. Deploy Backstage:

# Install Backstage CLI
npm install -g @backstage/cli

# Apply Backstage manifests
kubectl apply -f ../kubernetes/manifests/backstage/

# Wait for Backstage to be ready
kubectl rollout status deployment/backstage

# Port-forward to access Backstage
kubectl port-forward svc/backstage 8080:80

9. Access Backstage and deploy ML models:

- Open your browser and navigate to http://localhost:8080
- Use the Backstage catalog to browse available ML model templates
- Deploy a Hugging Face model using the self-service template

Deploying a Model Manually
You can also deploy a model directly using the provided script:

### Usage

Data scientists can use the Backstage interface to deploy machine learning models from Hugging Face onto the GKE cluster. The provided templates and scripts facilitate self-service deployments.

### Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.