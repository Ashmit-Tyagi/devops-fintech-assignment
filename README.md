# Devops Assignment

## Project Overview

### A microservices-based fintech application was designed and (partially) implemented using modern DevOps practices.

### Components:
    Backend: Node.js + Express (API + business logic)
    Frontend: Static HTML served via Nginx
    Database: PostgreSQL (AWS RDS)

## (a) Architecture Design

### AWS Architecture

The application is deployed on AWS using a multi-AZ, multi-region architecture to ensure high availability and fault tolerance.

### VPC Design

    CIDR Block: 10.0.0.0/16
    Two Availability Zones (AZ-1, AZ-2)

Each AZ contains:

    Public Subnet: Hosts Application Load Balancer (ALB)
    Private Subnet: Hosts EKS worker nodes and RDS database

This design ensures network isolation and improves security by keeping critical services private.

### Multi-Region Design

An Active-Passive strategy is used:

    Primary Region: us-east-1
    Secondary Region: us-west-2 (standby)

Failover is handled using DNS-based routing.


### High Availability Strategy

    Multi-AZ deployment for EKS and RDS
    Load balancer distributes traffic across AZs
    Auto-scaling ensures handling of variable workloads
    Secondary region provides disaster recovery
    
### Security Considerations

    Private subnets for backend and database
    Security groups restrict access (only backend → DB)
    No hardcoded credentials (use secrets)
    IAM roles used for secure service access

### Cost Trade-offs
    Active-passive reduces cost compared to active-active
    Multi-AZ RDS increases cost but removes single point of failure
    Medium-sized instances (e.g., t3.medium) balance performance and cost
    Auto-scaling prevents over-provisioning

## (b) Terraform Strategy

### Module Design

Infrastructure is defined using reusable Terraform modules:

    modules/
     ├── vpc/
     ├── eks/
     └── db/
     

    VPC module: Networking (subnets, routing)
    EKS module: Kubernetes cluster and node groups
    DB module: RDS PostgreSQL and subnet groups


### Remote State 
    State stored in S3 bucket
    State locking via DynamoDB


## Environment Separation

Separate folders for:

    dev
    prod

Each environment has:

    Independent configuration
    Separate state files

### Multi-Region Handling
    Terraform uses provider aliases for multiple regions
    Separate state maintained per region to avoid conflicts
    Cross-region replication configured for database

### Dependency Handling
    Outputs from modules reused across components
    Explicit dependencies ensure correct resource creation order

### Challenges
    State drift handled via refresh and locking
    Synchronization across regions adds complexity
    Managing dependencies across modules

## (c) Docker & Image Strategy

### Dockerfile Optimization
    Multi-stage builds used to reduce image size
    Alpine-based images for minimal footprint
    
### Backend:

    Installs only production dependencies
    Runs lightweight Node.js server
    
### Frontend:
    Served using Nginx
    Static content only

### Security
    Containers run as non-root users
    Minimal packages included
    No credentials stored inside images
    
### Image Versioning & Storage
    Images tagged using Git commit SHA
    Stored in container registry (e.g., DockerHub or ECR)
    
### CI/CD Integration
    Images built automatically on code push
    Tagged and pushed to registry
    Used by Kubernetes during deployment

## (d) Kubernetes Deployment

### Zero-Downtime Deployment
    RollingUpdate strategy used
    Readiness probes ensure only healthy pods receive traffic
    Old pods removed only after new pods are ready
    
### Autoscaling
    Horizontal Pod Autoscaler (HPA) based on CPU usage
    Minimum replicas: 2
    Scales automatically during high load
    
### Secret Management
    Credentials stored in Kubernetes Secrets
    Injected as environment variables
    No sensitive data in code or YAML

### Inter-Service Communication
    Services use ClusterIP for internal communication
    DNS-based service discovery inside cluster
    Frontend exposed via Ingress

### GitOps with Argo CD
    Kubernetes manifests stored in GitHub
    Argo CD continuously monitors repository

## (e) CI/CD Pipeline Design

### Pipeline Overview

CI/CD implemented using:

    GitHub Actions (CI)
    Argo CD (CD)

### Trigger Mechanism
    Pipeline runs on push to main branch
    
### Failure Handling
    If build fails → deployment stops
    Logs generated for debugging
    Stable version retained

## (f) Failure & Failover Scenario
### Scenario

    Primary region becomes unavailable.

### Traffic Failover
    Managed using Amazon Route 53
    Health checks detect failure
    DNS redirects traffic to secondary region
    
### Data Consistency
    RDS cross-region replication used
    Secondary region maintains near real-time copy
    Replica promoted to primary during failure
    
## Repository Structure

    fintech-devops/
     ├── backend/
     ├── frontend/
     ├── k8s/
     ├── terraform/
     └── .github/workflows/
     


<img width="277" height="786" alt="image" src="https://github.com/user-attachments/assets/60c32289-44a3-4683-bbef-87d3eee39097" />

