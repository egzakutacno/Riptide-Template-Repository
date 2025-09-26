#!/bin/bash

# Deployment script for Riptide Crypto Node Template
# This script helps deploy the application to various platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PLATFORM=""
ENVIRONMENT="production"
TAG="latest"
REGISTRY=""
NAMESPACE="default"

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --platform PLATFORM    Deployment platform (docker, kubernetes, aws, gcp, azure)"
    echo "  -e, --environment ENV       Environment (development, staging, production)"
    echo "  -t, --tag TAG              Docker image tag (default: latest)"
    echo "  -r, --registry REGISTRY    Docker registry URL"
    echo "  -n, --namespace NAMESPACE  Kubernetes namespace (default: default)"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --platform docker --environment production"
    echo "  $0 --platform kubernetes --environment staging --namespace crypto-nodes"
    echo "  $0 --platform aws --environment production --tag v1.0.0"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$PLATFORM" ]; then
    echo -e "${RED}❌ Platform is required${NC}"
    show_usage
    exit 1
fi

echo -e "${BLUE}🚀 Deploying Riptide Crypto Node Template${NC}"
echo -e "${BLUE}Platform: $PLATFORM${NC}"
echo -e "${BLUE}Environment: $ENVIRONMENT${NC}"
echo -e "${BLUE}Tag: $TAG${NC}"
echo ""

# Pre-deployment checks
echo -e "${YELLOW}🔍 Running pre-deployment checks...${NC}"

# Check if required files exist
REQUIRED_FILES=("package.json" "riptide.config.json" "hooks.js" "index.js")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status 0 "Required file exists: $file"
    else
        print_status 1 "Required file missing: $file"
        exit 1
    fi
done

# Check if .env exists for production
if [ "$ENVIRONMENT" = "production" ] && [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Warning: .env file not found for production deployment${NC}"
fi

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
if ./scripts/test.sh; then
    print_status 0 "All tests passed"
else
    print_status 1 "Tests failed"
    exit 1
fi

# Platform-specific deployment
case $PLATFORM in
    docker)
        echo -e "${YELLOW}🐳 Deploying with Docker...${NC}"
        
        # Build Docker image
        IMAGE_NAME="crypto-node"
        if [ -n "$REGISTRY" ]; then
            IMAGE_NAME="$REGISTRY/$IMAGE_NAME"
        fi
        
        echo "Building Docker image: $IMAGE_NAME:$TAG"
        docker build -t "$IMAGE_NAME:$TAG" .
        print_status $? "Docker image built"
        
        # Run container
        echo "Starting container..."
        docker run -d \
            --name crypto-node \
            -p 3000:3000 \
            --env-file .env \
            "$IMAGE_NAME:$TAG"
        print_status $? "Container started"
        
        echo -e "${GREEN}🎉 Deployment completed!${NC}"
        echo "Container is running on port 3000"
        echo "Health check: http://localhost:3000/health"
        ;;
        
    kubernetes)
        echo -e "${YELLOW}☸️  Deploying to Kubernetes...${NC}"
        
        # Check if kubectl is available
        if ! command -v kubectl &> /dev/null; then
            print_status 1 "kubectl not found. Please install kubectl first."
            exit 1
        fi
        
        # Create namespace if it doesn't exist
        kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
        print_status $? "Namespace created/verified"
        
        # Apply Kubernetes manifests
        if [ -f "k8s/deployment.yaml" ]; then
            kubectl apply -f k8s/ -n "$NAMESPACE"
            print_status $? "Kubernetes resources applied"
        else
            echo -e "${YELLOW}⚠️  Kubernetes manifests not found. Creating basic deployment...${NC}"
            
            # Create basic deployment
            cat > k8s-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crypto-node
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: crypto-node
  template:
    metadata:
      labels:
        app: crypto-node
    spec:
      containers:
      - name: crypto-node
        image: crypto-node:$TAG
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "$ENVIRONMENT"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /status
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: crypto-node-service
  namespace: $NAMESPACE
spec:
  selector:
    app: crypto-node
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
EOF
            
            kubectl apply -f k8s-deployment.yaml
            print_status $? "Basic Kubernetes deployment created"
            rm k8s-deployment.yaml
        fi
        
        echo -e "${GREEN}🎉 Kubernetes deployment completed!${NC}"
        echo "Check status with: kubectl get pods -n $NAMESPACE"
        ;;
        
    aws)
        echo -e "${YELLOW}☁️  Deploying to AWS...${NC}"
        echo "AWS deployment not implemented yet. Please use Docker or Kubernetes deployment."
        exit 1
        ;;
        
    gcp)
        echo -e "${YELLOW}☁️  Deploying to Google Cloud...${NC}"
        echo "GCP deployment not implemented yet. Please use Docker or Kubernetes deployment."
        exit 1
        ;;
        
    azure)
        echo -e "${YELLOW}☁️  Deploying to Azure...${NC}"
        echo "Azure deployment not implemented yet. Please use Docker or Kubernetes deployment."
        exit 1
        ;;
        
    *)
        echo -e "${RED}❌ Unknown platform: $PLATFORM${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Verify the deployment is running"
echo "2. Check health endpoints"
echo "3. Monitor logs and metrics"
echo "4. Set up monitoring and alerting"
