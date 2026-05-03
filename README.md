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
