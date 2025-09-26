# Deployment Guide

This guide covers deploying your Riptide-based crypto node service to various platforms.

## Prerequisites

- Node.js 18+ installed
- Docker (for containerized deployment)
- Git configured
- Environment variables set up

## Local Development

### 1. Clone and Setup

```bash
git clone <your-template-repo>
cd your-crypto-project
npm install
cp env.example .env
```

### 2. Configure Environment

Edit `.env` with your settings:
```bash
NODE_ENV=development
PORT=3000
SERVICE_NAME=your-crypto-node
# ... other settings
```

### 3. Start Development Server

```bash
npm run dev
```

## Docker Deployment

### 1. Create Dockerfile

```dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

### 2. Build and Run

```bash
# Build image
docker build -t your-crypto-node .

# Run container
docker run -d \
  --name crypto-node \
  -p 3000:3000 \
  --env-file .env \
  your-crypto-node
```

### 3. Docker Compose

```yaml
version: '3.8'
services:
  crypto-node:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    env_file:
      - .env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Kubernetes Deployment

### 1. Create Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: crypto-nodes
```

### 2. Create ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: crypto-node-config
  namespace: crypto-nodes
data:
  NODE_ENV: "production"
  PORT: "3000"
  SERVICE_NAME: "crypto-node"
```

### 3. Create Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: crypto-node-secrets
  namespace: crypto-nodes
type: Opaque
data:
  API_KEY: <base64-encoded-api-key>
  PRIVATE_KEY: <base64-encoded-private-key>
```

### 4. Create Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crypto-node
  namespace: crypto-nodes
spec:
  replicas: 3
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
        image: your-registry/crypto-node:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: crypto-node-config
              key: NODE_ENV
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: crypto-node-secrets
              key: API_KEY
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
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 5. Create Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: crypto-node-service
  namespace: crypto-nodes
spec:
  selector:
    app: crypto-node
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

## Cloud Platform Deployment

### AWS ECS

1. **Create ECS Task Definition**:

```json
{
  "family": "crypto-node",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "crypto-node",
      "image": "your-account.dkr.ecr.region.amazonaws.com/crypto-node:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "API_KEY",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:crypto-node/api-key"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/crypto-node",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Google Cloud Run

1. **Deploy with gcloud**:

```bash
gcloud run deploy crypto-node \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production
```

### Azure Container Instances

1. **Create container group**:

```bash
az container create \
  --resource-group myResourceGroup \
  --name crypto-node \
  --image your-registry.azurecr.io/crypto-node:latest \
  --cpu 1 \
  --memory 1 \
  --ports 3000 \
  --environment-variables NODE_ENV=production
```

## Production Considerations

### 1. Security

- Use HTTPS in production
- Implement proper authentication
- Rotate secrets regularly
- Use network policies (Kubernetes)
- Enable audit logging

### 2. Monitoring

- Set up health check endpoints
- Configure alerting
- Monitor resource usage
- Track application metrics
- Set up log aggregation

### 3. Scaling

- Use horizontal pod autoscaling (Kubernetes)
- Configure load balancers
- Monitor performance metrics
- Plan for traffic spikes

### 4. Backup and Recovery

- Backup configuration files
- Document recovery procedures
- Test disaster recovery
- Maintain multiple environments

## Environment-Specific Configuration

### Development
```bash
NODE_ENV=development
LOG_LEVEL=debug
RIPTIDE_DEBUG=true
```

### Staging
```bash
NODE_ENV=staging
LOG_LEVEL=info
RIPTIDE_DEBUG=false
```

### Production
```bash
NODE_ENV=production
LOG_LEVEL=warn
RIPTIDE_DEBUG=false
```

## Health Checks

### Application Health Check

```bash
curl http://localhost:3000/health
```

### Readiness Check

```bash
curl http://localhost:3000/status
```

### Metrics Endpoint

```bash
curl http://localhost:3000/metrics
```

## Troubleshooting

### Common Issues

1. **Container won't start**: Check logs and environment variables
2. **Health checks failing**: Verify endpoint responses
3. **Memory issues**: Adjust resource limits
4. **Network connectivity**: Check security groups and firewall rules

### Debug Commands

```bash
# Check container logs
docker logs crypto-node

# Check Kubernetes pod status
kubectl get pods -n crypto-nodes

# Check service endpoints
kubectl get endpoints -n crypto-nodes

# Debug pod
kubectl exec -it crypto-node-pod -- /bin/sh
```

## Next Steps

1. Set up CI/CD pipelines
2. Configure monitoring and alerting
3. Implement backup strategies
4. Plan for disaster recovery
5. Document operational procedures
