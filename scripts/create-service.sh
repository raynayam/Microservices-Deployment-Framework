#!/bin/bash

# Create New Microservice Script

set -e

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <service-name>"
    echo "Example: $0 payment-service"
    exit 1
fi

SERVICE_NAME=$1
REPO_DIR=$(git rev-parse --show-toplevel)
SRC_DIR="${REPO_DIR}/src/services/${SERVICE_NAME}"
KUBE_DIR="${REPO_DIR}/infrastructure/kubernetes/base/${SERVICE_NAME}.yaml"

# Check if service already exists
if [ -d "${SRC_DIR}" ]; then
    echo "Error: Service ${SERVICE_NAME} already exists at ${SRC_DIR}"
    exit 1
fi

# Create service directories
echo "Creating service structure for ${SERVICE_NAME}..."
mkdir -p "${SRC_DIR}"

# Create package.json
cat > "${SRC_DIR}/package.json" <<EOF
{
  "name": "${SERVICE_NAME}",
  "version": "1.0.0",
  "description": "${SERVICE_NAME} for microservices framework",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.4.0",
    "cors": "^2.8.5",
    "winston": "^3.8.2",
    "morgan": "^1.10.0",
    "helmet": "^6.0.1",
    "prom-client": "^14.2.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.22",
    "jest": "^29.5.0",
    "supertest": "^6.3.3"
  }
}
EOF

# Create server.js
cat > "${SRC_DIR}/server.js" <<EOF
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const promClient = require('prom-client');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('combined'));
app.use(express.json());

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).send({ status: 'ok' });
});

app.get('/readiness', (req, res) => {
  res.status(200).send({ status: 'ready' });
});

// Service routes
app.get('/${SERVICE_NAME}', (req, res) => {
  res.status(200).json({ message: 'Hello from ${SERVICE_NAME}' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'production' ? {} : err.message
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(\`${SERVICE_NAME} running on port \${PORT}\`);
});
EOF

# Create Dockerfile
cat > "${SRC_DIR}/Dockerfile" <<EOF
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

EXPOSE 8080

USER node

CMD ["node", "server.js"]
EOF

# Create Kubernetes manifest
cat > "${KUBE_DIR}" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}
  namespace: microservices
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${SERVICE_NAME}
  template:
    metadata:
      labels:
        app: ${SERVICE_NAME}
        version: v1
    spec:
      containers:
      - name: ${SERVICE_NAME}
        image: \${DOCKER_REGISTRY}/${SERVICE_NAME}:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /readiness
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: microservices
spec:
  selector:
    app: ${SERVICE_NAME}
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

# Create README.md
cat > "${SRC_DIR}/README.md" <<EOF
# ${SERVICE_NAME}

This is a microservice for the Microservices Deployment Framework.

## Running Locally

\`\`\`bash
npm install
npm run dev
\`\`\`

## API Endpoints

- GET /${SERVICE_NAME} - Main service endpoint
- GET /health - Health check endpoint
- GET /readiness - Readiness check endpoint
- GET /metrics - Prometheus metrics endpoint

## Building and Deploying

Build the Docker image:

\`\`\`bash
docker build -t ${SERVICE_NAME}:latest .
\`\`\`

Deploy to Kubernetes:

\`\`\`bash
kubectl apply -f kubernetes/${SERVICE_NAME}.yaml
\`\`\`
EOF

echo "Service ${SERVICE_NAME} created successfully!"
echo "Next steps:"
echo "1. Customize ${SRC_DIR}/server.js with your service logic"
echo "2. Update ${KUBE_DIR} with any additional configuration"
echo "3. Build and deploy the service using the deployment scripts" 