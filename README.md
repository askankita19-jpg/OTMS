# OTMS

**OTMS (Online/Organization/Operations Tracking Management System)** is a microservices-based application that I deployed on AWS using a traditional VM-based DevOps architecture.

In this project, I worked on automating the application deployment lifecycle using **Jenkins, Terraform, Ansible, Packer, and AWS EC2**. The main focus of the project is to understand and implement CI/CD, Infrastructure as Code, configuration management, immutable AMIs, security checks, and controlled application deployments.

---

## Project Overview

The OTMS application consists of a frontend and four backend microservices. Each service has its own responsibility and communicates with the required databases.

The application components are:

| Component        | Technology         | Port |
| ---------------- | ------------------ | ---: |
| Frontend         | React              | 3000 |
| Employee API     | Go                 | 8080 |
| Attendance API   | Python             | 8081 |
| Salary API       | Java / Spring Boot | 8082 |
| Notification API | Python             | 8085 |

The application uses the following databases:

| Database   | Port |
| ---------- | ---: |
| PostgreSQL | 5432 |
| Redis      | 6379 |
| ScyllaDB   | 9042 |

### Application Dependencies

```text
Employee API
 ├── ScyllaDB
 └── Redis

Attendance API
 ├── PostgreSQL
 └── Redis

Salary API
 ├── ScyllaDB
 └── Redis

Notification API
 └── ScyllaDB
```

---

## Architecture

The overall project flow is:

```text
                         Developer
                             |
                             v
                          GitHub
                             |
                             v
                          Jenkins
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
         Application       Packer       Terraform
             CI              |              |
              |              v              |
              |             AMI              |
              |              |               |
              +--------------+---------------+
                             |
                             v
                          Ansible
                             |
                             v
                         AWS / EC2
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
          Frontend        Backend          Databases
           :3000       APIs :8080-8085    PostgreSQL
                                           Redis
                                           ScyllaDB
```

The deployment separates the application build, AMI creation, infrastructure provisioning, and server configuration stages. This gives me a clear flow from application source code to the running application on AWS.

---

## DevOps Implementation

The main DevOps tools I used in this project are:

| Tool                   | Purpose                               |
| ---------------------- | ------------------------------------- |
| Git / GitHub           | Source code management                |
| Jenkins                | CI/CD orchestration                   |
| Jenkins Shared Library | Reusable pipeline logic               |
| Jenkins Job DSL        | Jenkins job creation                  |
| Terraform              | AWS infrastructure provisioning       |
| Packer                 | Application AMI creation              |
| Ansible                | Server and database configuration     |
| SonarQube              | Code quality and static analysis      |
| Trivy                  | Dependency and vulnerability scanning |
| Gitleaks               | Secret and credential scanning        |
| OWASP ZAP              | Dynamic application security testing  |
| AWS SSM                | Management of private infrastructure  |
| AWS EC2                | Application and infrastructure hosts  |

---

## Application CI

I implemented application CI pipelines to validate application changes before they move towards deployment.

The general CI flow is:

```text
Checkout
   |
   v
Gitleaks Scan
   |
   v
Code Formatting
   |
   v
Syntax Validation
   |
   v
Dependency Installation
   |
   v
Unit Tests
   |
   v
Dependency / Vulnerability Scan
   |
   v
SonarQube Analysis
   |
   v
DAST where applicable
   |
   v
Build Artifact
```

The exact build and validation steps depend on the technology used by each application.

For example, the project contains applications written using **Go, Python, Java/Spring Boot, and React**, so the CI pipeline handles the corresponding build, dependency, and validation requirements.

---

## Deployment Flow

After the application passes CI, the deployment moves through the following stages:

```text
Application CI
      |
      v
Validated Artifact
      |
      v
Packer
      |
      v
Application AMI
      |
      v
Terraform
      |
      v
AWS Infrastructure
      |
      v
Ansible
      |
      v
Application Configuration
      |
      v
EC2
      |
      v
Smoke Tests
```

This approach separates application validation from infrastructure provisioning and server configuration.

---

## Terraform

I used **Terraform** to provision the AWS infrastructure required for OTMS.

The infrastructure includes resources such as:

* VPC
* Subnets
* Route tables
* Security groups
* Network ACL support
* Application Load Balancer
* Target groups
* EC2 instances
* Auto Scaling resources
* IAM resources

Terraform allows me to maintain the infrastructure as code and recreate the environment using the same configuration.

The Terraform implementation is organized using modules so that common infrastructure components can be managed separately.

---

## Packer and Immutable AMIs

I used **Packer** to create application AMIs.

The idea is to build an AMI containing the required application setup instead of configuring the application manually on every new EC2 instance.

The flow is:

```text
Application Source
       |
       v
Jenkins CI
       |
       v
Validated Artifact
       |
       v
Packer
       |
       v
Application AMI
       |
       v
Terraform
       |
       v
EC2
```

Each AMI represents a particular application version. This also makes it easier to identify which application version is running on an EC2 instance.

---

## Ansible

I used **Ansible** for configuration management.

Ansible is responsible for configuring the required application and database hosts after the infrastructure is available.

Database configuration in the project includes:

* PostgreSQL
* Redis
* ScyllaDB

For private infrastructure, I integrated the deployment approach with **AWS Systems Manager (SSM)** instead of depending on direct public SSH access.

The general flow is:

```text
Terraform
   |
   v
EC2 Infrastructure
   |
   v
AWS SSM
   |
   v
Ansible
   |
   v
Server Configuration
```

---

## Jenkins CI/CD

Jenkins is the main CI/CD orchestration tool in this project.

I created separate pipelines for different parts of the deployment lifecycle, including:

* Application CI
* Packer AMI builds
* Terraform CI
* Terraform deployment
* Terraform destruction
* Ansible CI
* Ansible deployment
* Master deployment orchestration

I also used a **Jenkins Shared Library** to keep commonly used pipeline logic reusable instead of duplicating the same Groovy code across multiple pipelines.

For Jenkins job creation, I used **Jenkins Job DSL**. This allows Jenkins jobs to be created and managed through code.

---

## Master Pipeline

The Master Pipeline brings the major deployment stages together.

The overall deployment flow can be represented as:

```text
Application CI
      |
      v
Build Artifact
      |
      v
Packer AMI
      |
      v
Terraform
      |
      v
Infrastructure
      |
      v
Ansible
      |
      v
Application Configuration
      |
      v
Smoke Tests
```

This provides a single deployment flow while keeping the individual CI/CD components separately maintainable.

---

## Security Integration

Security checks are included as part of the CI/CD lifecycle.

### Gitleaks

I used **Gitleaks** to detect accidentally committed secrets and credentials in source code.

### SonarQube

I used **SonarQube** for static code analysis and code-quality checks.

### Trivy

I used **Trivy** for dependency and vulnerability scanning.

### OWASP ZAP

I used **OWASP ZAP** for dynamic application security testing where applicable.

The objective is to identify security and quality issues before the application reaches the deployment stage.

---

## Artifact Provenance

I designed the deployment flow so that the application version can be traced across the CI/CD lifecycle.

The important information includes:

* Git commit SHA
* Branch
* Jenkins build number
* Application artifact version
* Artifact checksum
* Packer build
* AMI ID
* Deployment information

This creates a relationship between the source code, build artifact, AMI, and the application running on AWS.

For example:

```text
Git Commit
    |
    v
Jenkins Build
    |
    v
Application Artifact
    |
    v
Packer Build
    |
    v
AMI
    |
    v
EC2 Deployment
```

---

## Rollback Approach

The deployment is based on versioned application artifacts and AMIs.

If an issue is identified with the currently deployed version, the deployment can be associated with a previously validated AMI.

```text
Current Version
      |
      v
Issue Detected
      |
      v
Previous Known-Good AMI
      |
      v
Deployment
      |
      v
Validation
```

This approach avoids depending on a mutable `latest` artifact for rollback.

---

## Infrastructure and Application Flow

At a high level, the complete OTMS deployment lifecycle is:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +-------------------+
    |                   |
    v                   v
Application CI       Terraform
    |                   |
    v                   v
Artifact             AWS Infrastructure
    |                   |
    v                   |
Packer                 |
    |                   |
    v                   |
Application AMI <------+
    |
    v
Ansible / SSM
    |
    v
EC2
    |
    v
Application
    |
    v
Smoke Tests
```

---

## Repository Structure

The OTMS repository contains the DevOps and infrastructure components used to deploy the application on AWS.

```text
OTMS/
│
├── Jenkins/
├── Shared_Library/
├── Job_DSL/
├── Terraform/
├── Ansible/
├── Packer/
│
└── README.md
```

The application services are maintained in their respective repositories:

```text
Frontend
Employee API
Attendance API
Salary API
Notification API
```

The OTMS repository brings these application components into the deployment lifecycle through Jenkins, Packer, Terraform, and Ansible.

---

## Deployment Lifecycle

The complete lifecycle implemented in this project is:

```text
CODE
  ↓
CI
  ↓
SECURITY CHECKS
  ↓
VALIDATED ARTIFACT
  ↓
AMI
  ↓
INFRASTRUCTURE
  ↓
CONFIGURATION
  ↓
DEPLOYMENT
  ↓
VALIDATION
  ↓
ROLLBACK
```

This project helped me bring together the different DevOps concepts I worked with — **Git, Jenkins, Terraform, Packer, Ansible, AWS, security scanning, CI/CD automation, and deployment validation** — into one end-to-end application deployment workflow.

---

## Project Goal

The main goal of this project is to implement a **repeatable and automated VM-based DevOps deployment for a microservices application on AWS**.

Rather than treating CI/CD, infrastructure, configuration management, and application deployment as separate activities, I connected them into a single workflow:

```text
Source Code
     ↓
CI
     ↓
Security & Quality Checks
     ↓
Artifact
     ↓
AMI
     ↓
Terraform Infrastructure
     ↓
Ansible Configuration
     ↓
EC2 Deployment
     ↓
Smoke Testing
```

This represents the overall approach I followed while building the OTMS project.
