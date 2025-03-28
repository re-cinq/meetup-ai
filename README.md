# GKE GPU Backstage Demo

This project demonstrates how to deploy a Kubernetes cluster on Google Kubernetes Engine (GKE) with GPU access using Terraform. It also showcases self-service capabilities for data scientists through Backstage, allowing them to deploy machine learning models from Hugging Face onto the cluster via Flux.

## Project Structure

```
meetup-ai/
├── .env                             # Environment variables
├── README.md                        # Project documentation
├── terraform/
│   ├── main.tf                      # Main Terraform configuration
│   ├── variables.tf                 # Define Terraform variables
│   ├── providers.tf                 # Provider configuration
│   ├── gke.tf                       # GKE cluster configuration
│   └── outputs.tf                   # Output values
├── kubernetes/
│   ├── flux-system/                 # Generated by Flux bootstrap
│   └── manifests/
│   |   ├── backstage/
│   |   │   ├── deployment.yaml      # Backstage deployment
│   |   │   ├── service.yaml         # Backstage service
│   |   │   └── configmap.yaml       # Backstage configuration
|   |   |   |__ ingress.yaml
|   |   |   |__ namespace.yaml
|   |   |   |__ pg-svc.yaml
|   |   |   |__ postgres.yaml
|   |   |   |__ rbac.yaml
│   |   └── ml-models/
│   |       ├── huggingface-deployment.yaml  # Hugging Face model deployment
│   |       ├── gpu-resources.yaml           # GPU resources configuration
│   |       └── service.yaml                 # Service for model endpoints
|   |       |__ namespace.yaml
|   |       |__ nvidia-rbac.yaml
|   |       |__ kustomization.yaml
|   |__ kustomization.yaml
|
├── backstage/
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
```
# Run this to get access to GitHub for Backstage
kubectl create secret generic backstage-secrets \
  --namespace backstage \
  --from-literal=github-token=YOUR_GITHUB_PAT_HERE
```
7. Run Flux on the cluster:

# Bootstrap Flux (replace with your Git repository)
```bash
# For personal GitHub accounts:
export GITHUB_USER=<your-github-username>
export GITHUB_REPO=<your-github-repo>

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --path=kubernetes \
  --personal

# OR for organization GitHub accounts:
export GITHUB_OWNER=<your-org-name>
export GITHUB_REPO=<your-github-repo>

flux bootstrap github \
  --owner=$GITHUB_OWNER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=kubernetes \
  --token-auth
```

# Port-forward to access Backstage
kubectl port-forward svc/backstage 8080:80

8. Access Backstage and deploy ML models:

- Open your browser and navigate to http://localhost:8080
- Use the Backstage catalog to browse available ML model templates
- Deploy a Hugging Face model using the self-service template
- `https://github.com/backstage/backstage/blob/master/plugins/scaffolder-backend/sample-templates/remote-templates.yaml`
- `https://github.com/re-cinq/meetup-ai/blob/main/backstage/templates/ml-model-template.yaml`

Deploying a Model Manually
You can also deploy a model directly using the provided script:

## Usage Examples

Here are some example Hugging Face models you can deploy:

- Text generation: `gpt2`
- Image classification: `google/vit-base-patch16-224`
- Speech recognition: `facebook/wav2vec2-base-960h`

## Clean Up

To avoid incurring charges, remove all resources when you're done:

```bash
cd terraform
terraform destroy
```
### Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.