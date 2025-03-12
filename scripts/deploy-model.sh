#!/bin/bash

# Script to deploy a Hugging Face model to Kubernetes

MODEL_NAME=${1:-"bert-base-uncased"}
NAMESPACE=${2:-"default"}
GPU_COUNT=${3:-"1"}
REPLICAS=${4:-"1"}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "Cannot connect to Kubernetes cluster. Please check your configuration."
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment YAML
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${MODEL_NAME}-model
  namespace: ${NAMESPACE}
  labels:
    app: ${MODEL_NAME}-model
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: ${MODEL_NAME}-model
  template:
    metadata:
      labels:
        app: ${MODEL_NAME}-model
    spec:
      containers:
      - name: ${MODEL_NAME}-model
        image: huggingface/transformers-pytorch-gpu:latest
        resources:
          limits:
            nvidia.com/gpu: ${GPU_COUNT}
        ports:
        - containerPort: 8000
        env:
        - name: MODEL_NAME
          value: "${MODEL_NAME}"
        command: ["/bin/bash", "-c"]
        args:
          - |
            pip install transformers[torch] fastapi uvicorn
            python -c "
            from transformers import AutoModel, AutoTokenizer
            import torch
            import uvicorn
            from fastapi import FastAPI
            
            app = FastAPI()
            tokenizer = AutoTokenizer.from_pretrained('${MODEL_NAME}')
            model = AutoModel.from_pretrained('${MODEL_NAME}').to('cuda')
            
            @app.get('/health')
            def health():
                return {'status': 'ok'}
                
            @app.post('/predict')
            def predict(text: str):
                inputs = tokenizer(text, return_tensors='pt').to('cuda')
                with torch.no_grad():
                    outputs = model(**inputs)
                return {'embeddings': outputs.last_hidden_state[:,0,:].cpu().numpy().tolist()}
                
            uvicorn.run(app, host='0.0.0.0', port=8000)
            "
      nodeSelector:
        gpu-node: "true"
      tolerations:
      - key: "nvidia.com/gpu"
        operator: "Equal"
        value: "present"
        effect: "NoSchedule"
---
apiVersion: v1
kind: Service
metadata:
  name: ${MODEL_NAME}-model
  namespace: ${NAMESPACE}
spec:
  selector:
    app: ${MODEL_NAME}-model
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
EOF

# Apply the deployment
kubectl apply -f deployment.yaml
rm deployment.yaml

echo "Model ${MODEL_NAME} deployed to namespace ${NAMESPACE} with ${GPU_COUNT} GPUs and ${REPLICAS} replicas"
echo "To access the model API: kubectl port-forward -n ${NAMESPACE} svc/${MODEL_NAME}-model 8000:80"