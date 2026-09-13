# OTMS

**OTMS (Organization/Online Talent Management System)** is a microservices-based application implemented as a traditional VM/EC2 deployment model.

This repository represents the **baseline OTMS deployment architecture**, where application delivery is automated through **Jenkins**, infrastructure is provisioned using **Terraform**, server configuration is managed using **Ansible**, and application AMIs are created using **Packer**.

> **Important:** Docker and Kubernetes/EKS are intentionally **not part of this repository**. They are implemented independently in the `OTMS-Docker` and `OTMS-EKS` repositories.

---

## Architecture

```text
                         GitHub
                            |
                            v
                         Jenkins
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
        Application       Packer       Terraform
             CI             |             |
              |              v             v
              |             AMI        AWS Infrastructure
              |                              |
              +------------------------------+
                             |
                           Ansible
                             |
                             v
                            EC2
                             |
                +------------+------------+
                |            |            |
                v            v            v
            Frontend       APIs        Database
             :3000       :8080-8085    Services
```

---

## Application Components

OTMS consists of five application services:

| Component        | Technology         | Port |
| ---------------- | ------------------ | ---: |
| Frontend         | React              | 3000 |
| Employee API     | Go                 | 8080 |
| Attendance API   | Python             | 8081 |
| Salary API       | Java / Spring Boot | 8082 |
| Notification API | Python             | 8085 |

The application uses:

| Database   | Port |
| ---------- | ---: |
| PostgreSQL | 5432 |
| Redis      | 6379 |
| ScyllaDB   | 9042 |

Application/database relationships include Employee API with ScyllaDB and Redis, Attendance API with PostgreSQL and Redis, Salary API with ScyllaDB and Redis, and Notification API with ScyllaDB.

---

## DevOps Technologies

* AWS
* Jenkins
* Jenkins Shared Libraries
* Jenkins Job DSL
* Terraform
* Ansible
* Packer
* Git
* SonarQube
* Trivy
* Gitleaks
* OWASP ZAP
* AWS Systems Manager / SSM
* Amazon EC2
* Application Load Balancer

---

## CI/CD Flow

The application delivery workflow is:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +--> Gitleaks
    |
    +--> Formatting / Syntax Checks
    |
    +--> Unit Tests
    |
    +--> Trivy
    |
    +--> SonarQube
    |
    +--> DAST
    |
    v
Application Artifact
    |
    v
Packer
    |
    v
AMI
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
Application Deployment
    |
    v
Smoke Tests
```

---

## Jenkins

Jenkins is the primary CI/CD control plane.

The repository contains pipelines for:

* Application CI
* Packer
* Ansible CI
* Ansible CD
* Terraform CI
* Terraform CD
* Terraform Destroy
* Master orchestration

The original OTMS implementation uses a master pipeline with actions such as verification, full deployment and destruction.

---

## Jenkins Shared Library

Reusable pipeline logic is maintained through a dedicated Shared Library structure.

The Shared Library provides reusable functions for:

* Application CI
* Go services
* Java services
* Python services
* React services
* Packer
* Terraform
* Ansible
* Notifications
* Static analysis
* Dependency scanning
* Unit testing
* DAST

This keeps Jenkinsfiles small and promotes reuse across application pipelines.

---

## Job DSL

Jenkins Job DSL is used to generate and maintain the Jenkins job hierarchy.

The generated jobs cover the application CI, Packer, Ansible, Terraform and orchestration workflows.

---

## Terraform

Terraform manages AWS infrastructure as code.

The infrastructure includes components such as:

* VPC
* Subnets
* Route tables
* Security groups
* Network ACLs
* Application Load Balancer
* Target groups
* EC2 instances / Auto Scaling
* IAM resources
* Supporting AWS infrastructure

Terraform is organized using reusable modules.

---

## Ansible

Ansible is responsible for configuration management.

Database configuration includes:

```text
PostgreSQL
Redis
ScyllaDB
```

Private database hosts are managed using AWS Systems Manager/SSM rather than requiring direct public SSH access.

---

## Packer

Packer creates application AMIs from validated application artifacts.

The objective is to maintain immutable, traceable application images that can be consumed by Terraform.

Artifact provenance is maintained through build metadata and hashes.

---

## Security

Security checks are integrated into the CI workflow.

### Source security

**Gitleaks**

Detects accidentally committed credentials and secrets.

### Static analysis

**SonarQube**

Performs code quality and static analysis.

### Dependency and vulnerability scanning

**Trivy**

Scans dependencies and applicable artifacts for vulnerabilities.

### DAST

**OWASP ZAP**

Provides dynamic application security testing where applicable.

---

## Deployment Principle

This repository is designed to be **independently deployable**.

The official deployment path is:

```text
Jenkins
   |
   +--> CI
   |
   +--> Packer
   |
   +--> Terraform
   |
   +--> Ansible
   |
   v
AWS EC2
```

It does not require:

* `OTMS-Docker`
* `OTMS-EKS`
* `OTMS-Monitoring`

to be deployed.

---

## Rollback

Application deployment uses versioned artifacts and AMIs so that a previously validated version can be restored.

Conceptually:

```text
Current AMI
     |
     | failure
     v
Previous Known-Good AMI
     |
     v
Terraform
     |
     v
EC2
```

---

## Repository Evolution

This repository is the first deployment generation of the OTMS project.

```text
OTMS
 |
 | Traditional VM deployment
 |
 v
OTMS-Docker
 |
 | Containerization
 |
 v
OTMS-EKS
 |
 | Kubernetes orchestration
 |
 v
OTMS-Monitoring
 |
 | Observability
```

---

## Project Goals

The goals of this repository are to demonstrate:

* CI/CD automation
* Infrastructure as Code
* Configuration management
* Immutable AMI-based deployments
* Automated security checks
* Jenkins Shared Libraries
* Jenkins Job DSL
* AWS infrastructure automation
* Deployment rollback
* Reproducible deployments

---

## Important Notes

This repository represents the **traditional OTMS deployment model**.

Docker and Kubernetes are intentionally separated into their own repositories:

* `OTMS-Docker`
* `OTMS-EKS`

Monitoring is also maintained separately:

* `OTMS-Monitoring`

This separation allows every deployment model to be independently deployed and tested.

---

## Project Status

🚧 **Under Development**

The repository is being rebuilt and enhanced as part of a complete DevOps learning and portfolio project.

---

## Related Repositories

* **OTMS** — Traditional EC2/AMI deployment
* **OTMS-Docker** — Docker-based deployment
* **OTMS-EKS** — Kubernetes/EKS deployment
* **OTMS-Monitoring** — Monitoring and deployment orchestration

---

## Author

**Ankita**

DevOps / Cloud Engineering Project
