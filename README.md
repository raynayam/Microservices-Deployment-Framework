# Microservices Deployment Framework

A comprehensive framework for deploying and managing microservices with service mesh integration and advanced traffic management capabilities.

## Features

- **Infrastructure as Code (IaC)** using Terraform and Kubernetes manifests
- **Service Mesh Integration** with Istio for advanced networking features
- **GitOps Workflow** using ArgoCD for continuous deployment
- **Observability Stack** with Prometheus, Grafana, and Jaeger
- **Advanced Traffic Management** including canary deployments, circuit breaking, and traffic mirroring
- **Security Features** including mTLS, RBAC, and network policies
- **Sample Microservices** demonstrating the framework's capabilities

## Architecture

![Architecture Diagram](docs/images/architecture.png)

The framework consists of the following components:

- **Infrastructure Layer**: Kubernetes cluster provisioning using Terraform
- **Service Mesh Layer**: Istio for service-to-service communication and traffic management
- **Deployment Layer**: ArgoCD for GitOps-based continuous deployment
- **Monitoring Layer**: Prometheus, Grafana, and Jaeger for observability
- **Sample Microservices**: API Gateway, Auth Service, User Service, and Product Service

## Getting Started

### Prerequisites

- Docker
- Kubernetes cluster (local or remote)
- kubectl
- Helm
- Terraform

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/microservices-deployment-framework.git
cd microservices-deployment-framework
```

2. Set up the infrastructure:

```bash
cd infrastructure/terraform
terraform init
terraform apply
```

3. Install the service mesh:

```bash
cd ../service-mesh
./install.sh
```

4. Deploy the sample microservices:

```bash
cd ../../
./scripts/deploy-services.sh
```

## Usage Examples

### Deploying a New Microservice

```bash
./scripts/create-service.sh my-new-service
```

### Implementing Canary Deployment

```bash
./scripts/canary-deploy.sh user-service v2 20
```

### Traffic Mirroring for Testing

```bash
./scripts/mirror-traffic.sh product-service v2
```

## Project Structure

```
├── infrastructure/             # Infrastructure components
│   ├── kubernetes/             # Kubernetes manifests
│   ├── service-mesh/           # Service mesh configuration
│   ├── monitoring/             # Monitoring stack setup
│   └── terraform/              # Terraform IaC for cluster provisioning
├── src/                        # Source code for sample microservices
│   └── services/               # Individual microservices
├── scripts/                    # Utility scripts
└── docs/                       # Documentation
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 