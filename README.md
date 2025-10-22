# Jenkins Pipeline Files for Microservices

This repository contains Jenkins pipeline files for all microservices in the Shopy-shopy application. Each microservice has its own branch with a dedicated Jenkins pipeline file.

## Repository Structure

```
Jenkins-file-microservices/
├── main (emailservice Jenkins file + README)
├── adservice/ (jenkisfile-adservice)
├── cartservice/ (jenkisfile-cartservice)
├── checkoutservice/ (jenkisfile-checkoutservice)
├── currencyservice/ (jenkisfile-currencyservice)
├── frontend/ (jenkisfile-frontend)
├── loadgenerator/ (jenkisfile-loadgenerator)
├── paymentservice/ (jenkisfile-paymentservice)
├── productcatalogservice/ (jenkisfile-productcatalogservice)
├── recommendationservice/ (jenkisfile-recommendationservice)
└── shippingservice/ (jenkisfile-shippingservice)
```

## Microservices

This repository contains Jenkins pipeline files for the following microservices:

- **emailservice**: Email notification service (main branch)
- **adservice**: Advertisement service
- **cartservice**: Shopping cart service (includes Redis)
- **checkoutservice**: Checkout processing service
- **currencyservice**: Currency conversion service
- **frontend**: Web frontend service
- **loadgenerator**: Load testing service
- **paymentservice**: Payment processing service
- **productcatalogservice**: Product catalog service
- **recommendationservice**: Product recommendation service
- **shippingservice**: Shipping calculation service

## Jenkins Pipeline Features

Each Jenkins pipeline includes:

1. **Get Latest Tag**: Fetches the latest image tag from Google Cloud Registry
2. **Sync Image to ECR**: Pulls images from GCP and pushes to AWS ECR
3. **Verify Sync**: Verifies that images are successfully synced to ECR
4. **Update Helm Chart and Push**: Updates Helm charts with new image tags and pushes to GitHub

## Prerequisites

- Jenkins with Docker support
- AWS credentials configured in Jenkins
- GitHub token configured in Jenkins
- Docker installed on Jenkins agents
- AWS CLI and Helm installed on Jenkins agents

## Required Jenkins Credentials

- `aws-creds`: AWS credentials for ECR access
- `github-token`: GitHub personal access token for repository access

## Usage

1. **Clone the repository**:
   ```bash
   git clone git@github.com:Amaldeep98/Jenkins-file-microservices.git
   cd Jenkins-file-microservices
   ```

2. **Checkout the desired microservice branch**:
   ```bash
   git checkout adservice
   ```

3. **Create Jenkins job** using the pipeline file:
   - Go to Jenkins dashboard
   - Create new Pipeline job
   - Set Pipeline script from SCM
   - Configure Git repository and branch
   - Use the Jenkinsfile from the respective branch

## Pipeline Configuration

Each pipeline is configured with:

- **AWS Region**: `us-east-1`
- **ECR URI**: `183611507646.dkr.ecr.us-east-1.amazonaws.com`
- **GitHub Repository**: `https://github.com/Amaldeep98/microservice-helm-charts.git`
- **Source Registry**: Google Cloud Registry (`us-central1-docker.pkg.dev`)

## Branch Strategy

- **main**: Contains emailservice Jenkins file (reference) + README
- **{microservice-name}**: Each microservice has its own branch with its Jenkins pipeline file

## License

This project is licensed under the Apache License 2.0.
