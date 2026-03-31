## Overview

This repository showcases a full-stack application deployment built with modern DevOps and cloud-native approaches. It highlights the use of Infrastructure as Code (IaC), containerization, orchestration, and automated CI/CD pipelines to deliver a scalable and efficient deployment workflow.

This project demonstrates a complete DevOps lifecycle for a cloud-native application, including:

- Automated infrastructure provisioning using Terraform
- Container orchestration with Kubernetes (Amazon EKS)
- CI/CD pipeline implementation with Jenkins
- Artifact repository management using Nexus
- Code quality analysis with SonarQube
- Security scanning through CodeQL and Veracode
- Monitoring and observability for system performance and reliability

## Architecture

![Architecture](/img/architecture.png)

## IaC - Terraform

The infrastructure is completely automated using Terraform with state management and locking enabled through AWS S3.

## VPC Architecture

- Public Subnet: Hosts Bastion Host, VPN, and ALB (Ingress Controller)
- Private Subnet: Houses EKS Cluster
- DB Subnet: Contains RDS (MySQL)
- CIDR blocks properly segmented for each subnet
- NAT Gateway for private subnet internet access
- Internet Gateway for public subnet

### Additional AWS Services

- Route53 for DNS management and service discovery
- CloudFront CDN for static content delivery
- EFS for persistent storage with proper mount targets
- Amazon ECR for secure container registry
- S3 buckets for artifact storage and Terraform state
- KMS for encryption key management

## Terraform Structure

```bash
terraform/
├── 01-vpc/          # VPC and networking
├── 02-sg/           # Security Groups
├── 03-bastion/      # Bastion Host
├── 04-db/           # RDS Database
├── 05-eks/          # EKS Cluster
├── 06-acm/          # SSL Certificates
├── 07-ingress-alb/  # ALB Ingress
└── 08-ecr/          # Container Registry
```

## Kubernetes Architecture - EKS

Our application runs on Amazon EKS (Elastic Kubernetes Service) with the following setup:

### Cluster Configuration

- EKS version: 1.32+
- Node groups: Combination of on-demand and spot instances
- Auto-scaling enabled (2–10 nodes)
- Multi-AZ deployment for high availability

### Components

#### Traffic Flow

- AWS Application Load Balancer (ALB) as the entry point
- Ingress Controller for traffic routing
  - URL path-based routing
  - SSL termination
  - Rate limiting
- Kubernetes Services
  - ClusterIP for internal communication
  - NodePort for debugging purposes
  - LoadBalancer for exposing external services

#### Application Management

- Deployments
  - Rolling update strategy
  - Resource requests and limits
  - Liveness and readiness probes

- ConfigMaps
  - Environment-specific configurations
  - Feature flags
  - Application settings

- Secrets
  - Secure credentials management
  - Sensitive configuration storage

- Helm Charts
  - Application packaging
  - Version control
  - Dependency management

- Storage
  - EFS-based StorageClass
  - PersistentVolumeClaims (PVCs)
  - Dynamic volume provisioning

### Helm Chart Structure

```bash
helm/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── hpa.yaml
```

## 🚀 CI/CD Pipeline - Jenkins

The continuous integration and deployment (CI/CD) pipeline is implemented using Jenkins and is automatically triggered via GitHub webhooks.

### Pipeline Architecture

- Multi-branch pipeline setup
- Shared libraries for reusable functions
- Parallel execution for optimized performance
- Built-in timeout and retry mechanisms
- Slack and email notifications for pipeline status

### Pipeline Stages

#### 1. Build Initialization

- Dependency installation
- Source code checkout
- Environment validation
- Cache restoration

#### 2. Code Quality

- SonarQube analysis
  - Code coverage enforcement
  - Detection of security hotspots
  - Identification of code smells
- Code coverage reporting
- Unit testing
- Integration testing

#### 3. Infrastructure

- Terraform plan and apply
- Infrastructure validation
- Security group verification
- Network connectivity testing

#### 4. Containerization

- Multi-stage Docker builds
- Docker image creation
  - Layer optimization
  - Security scanning
- Push images to Amazon ECR
- Image vulnerability scanning

#### 5. Deployment

- Helm chart validation
- Kubernetes manifest generation
- Rolling updates deployment strategy
- Smoke testing
- Rollback mechanisms

### Jenkinsfile Structure

- Declarative pipeline syntax
- Modular stage definitions
- Integration with shared libraries
- Environment-specific configurations

```groovy
pipeline {
    agent {
        label 'AGENT-1'
    }
    environment {
        // Environment variables
    }
    stages {
        stage('Build') {
            // Build stage
        }
        stage('Test') {
            // Test stage
        }
        // Additional stages
    }
    post {
        // Post-build actions
    }
}
```

## Setup Instructions

### Prerequisites

- AWS Account with appropriate permissions
- Domain name for application
- GitHub repository
- Docker installed locally
- kubectl and helm installed
- Terraform installed

### 1. Jenkins Setup

1. Create EC2 instance for Jenkins
   - Instance type: t3.large (minimum)
   - Storage: 30GB+ EBS
   - Security Group: Ports 22, 8080
2. Execute the setup script:

   ```bash
   sh jenkins.sh
   ```

3. Access Jenkins UI at `http://<jenkins-ip>:8080`
4. Follow initial setup wizard using the password from:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

5. Install required plugins:
   - Pipeline
   - Git
   - Docker
   - Kubernetes
   - SonarQube Scanner
   - Nexus Artifact Uploader

### 2. Jenkins Agent Setup

1. Create EC2 instance for Jenkins agent
   - Instance type: t3.medium (minimum)
   - Storage: 50GB+ EBS
2. Configure AWS credentials:

   ```bash
   aws configure
   ```

3. Run the agent setup script:

   ```bash
   sh jenkins-agent.sh
   ```

4. Install required tools:
   - Docker
   - kubectl
   - helm
   - terraform
   - aws-cli

### 3. Nexus Repository Setup

1. Access Nexus UI at `http://<nexus-ip>:8081`
2. Create Maven repositories:
   - Create hosted repository named "backend"
   - Set version policy to "mixed"
   - Set layout policy to "permissive"
   - Allow redeployment
3. Configure Jenkins-Nexus integration:
   - Install "Nexus Artifact Uploader" plugin in Jenkins
   - Add Nexus credentials in Jenkins
   - Configure repository URLs
4. Create Docker repository:
   - Type: hosted
   - HTTP port: 8083
   - Enable Docker V1 API

### 4. SonarQube Setup

1. Launch SonarQube instance (t3.medium recommended)
   - Instance type: t3.medium
   - Storage: 30GB EBS
   - Security Group: Ports 22, 9000
2. Access SonarQube UI at `http://<sonarqube-ip>:9000`
3. Jenkins Integration:
   - Install SonarQube Scanner plugin
   - Configure SonarQube server in Jenkins
   - Add authentication token
   - Setup webhooks for analysis feedback
4. Configure Quality Gates:
   - Code Coverage: 80%
   - Duplicated Lines: 3%
   - Maintainability Rating: A
   - Security Rating: A
   - Reliability Rating: A

## Monitoring and Security

### Monitoring Stack

- Metrics
  - Prometheus for metrics collection
  - Grafana for visualization
  - Custom dashboards for:
    - Application metrics
    - Infrastructure metrics
    - Business metrics
- Logging
  - ELK Stack
  - Log rotation
  - Log aggregation
- Alerting
  - PagerDuty integration
  - Slack notifications
  - Email alerts

### Security Measures

- Quality Gates:
  - Configured in SonarQube for code quality metrics
  - Branch protection rules
  - Required reviews
- Security Scanning:
  - CodeQL analysis enabled
  - DAST scanning using Veracode
  - Container scanning
  - Dependency scanning
- Monitoring:
  - Kubernetes metrics
  - Application performance monitoring
  - Infrastructure health checks
  - Custom metrics

## Security Best Practices

### Infrastructure Security

- Bastion host for secure access
- Private subnets for sensitive resources
- IAM roles and policies
- Network security groups
- Regular security scanning
- Encrypted communication

### Application Security

- HTTPS everywhere
- WAF rules
- Rate limiting
- Input validation
- Output encoding
- CSRF protection
- XSS prevention

### CI/CD Security

- Secrets management
- Pipeline security
- Image scanning
- Dependency checking
- Compliance validation
