# OTMS

**OTMS (Online/Organization/Operations Tracking Management System)** is a microservices-based application deployed on AWS using a traditional VM-based DevOps architecture.

This repository implements an automated CI/CD and infrastructure workflow using **Jenkins, Terraform, Ansible, Packer, and AWS EC2**.

The deployment is designed around immutable application artifacts, infrastructure as code, configuration management, automated validation, security checks, and controlled deployments.

---

## Architecture

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
          Application      Packer       Infrastructure
              CI             |          Terraform
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

---

## Application Components

| Component        | Technology         | Port |
| ---------------- | ------------------ | ---: |
| Frontend         | React              | 3000 |
| Employee API     | Go                 | 8080 |
| Attendance API   | Python             | 8081 |
| Salary API       | Java / Spring Boot | 8082 |
| Notification API | Python             | 8085 |

### Databases

| Database   | Port |
| ---------- | ---: |
| PostgreSQL | 5432 |
| Redis      | 6379 |
| ScyllaDB   | 9042 |

---

## Application Dependencies

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

## DevOps Architecture

The repository uses the following technologies:

* **Git** — source-code management
* **Jenkins** — CI/CD orchestration
* **Jenkins Shared Library** — reusable pipeline logic
* **Jenkins Job DSL** — automated job creation
* **Terraform** — AWS infrastructure provisioning
* **Ansible** — server and database configuration
* **Packer** — immutable application AMI creation
* **SonarQube** — static code analysis
* **Trivy** — dependency and security scanning
* **Gitleaks** — credential and secret scanning
* **OWASP ZAP** — dynamic application security testing where applicable
* **AWS Systems Manager (SSM)** — management of private infrastructure

---

## CI Workflow

Application CI performs automated validation before deployment.

```text
Checkout
   |
   v
Credential / Secret Scan
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
Dependency / License Scan
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

---

## Deployment Workflow

The deployment workflow follows:

```text
Application CI
      |
      v
Artifact
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

---

## Infrastructure

Terraform manages the AWS infrastructure required by the application, including resources such as:

* VPC
* Subnets
* Route tables
* Security groups
* Network ACLs
* Application Load Balancer
* Target groups
* EC2 instances
* Auto Scaling resources
* IAM resources
* Supporting infrastructure

Infrastructure is maintained as code to provide repeatable and auditable deployments.

---

## Configuration Management

Ansible manages application and database host configuration.

Database configuration includes:

* PostgreSQL
* Redis
* ScyllaDB

Private infrastructure can be managed using AWS Systems Manager rather than requiring direct public SSH access.

---

## Immutable AMI Strategy

Packer is used to create application AMIs from validated application artifacts.

The deployment process follows the principle:

```text
Source Code
    |
    v
CI Build
    |
    v
Validated Artifact
    |
    v
Packer
    |
    v
Versioned AMI
    |
    v
Terraform Deployment
```

Each deployment can therefore be associated with a specific application version and source revision.

---

## Artifact Provenance

Build information should remain traceable throughout the deployment lifecycle.

Important metadata includes:

* Git commit SHA
* Branch
* CI build number
* Artifact version
* Artifact checksum
* Packer build
* AMI ID
* Deployment information

This provides a clear relationship between source code and the infrastructure running that version.

---

## Jenkins

Jenkins acts as the primary CI/CD orchestration platform.

The pipeline design supports:

* Application CI
* Packer builds
* Ansible validation
* Ansible deployment
* Terraform validation
* Terraform deployment
* Controlled infrastructure destruction
* Master deployment orchestration
* Build notifications

Reusable pipeline functionality is maintained through the Jenkins Shared Library.

Jenkins Job DSL is used to automate Jenkins job creation and configuration.

---

## Security

Security checks are incorporated into the CI/CD lifecycle.

### Source Security

**Gitleaks** is used to identify accidentally committed credentials and secrets.

### Static Analysis

**SonarQube** is used for code-quality and static analysis.

### Dependency Security

**Trivy** is used for dependency and vulnerability scanning.

### Dynamic Testing

**OWASP ZAP** can be used for dynamic application security testing where applicable.

Secrets and credentials should not be committed to source control.

---

## Deployment Principles

This repository follows these principles:

1. Infrastructure is managed as code.
2. Application artifacts are validated before deployment.
3. Application AMIs are versioned and immutable.
4. Secrets are supplied through secure configuration mechanisms.
5. Deployment is performed through Jenkins.
6. Private infrastructure is not exposed unnecessarily to the public internet.
7. Deployment provenance is retained.
8. Infrastructure changes are reviewed through Terraform plans.
9. Destructive operations are controlled.
10. Deployment and rollback should use known versions rather than mutable `latest` artifacts.

---

## Rollback

Rollback should use a previously validated application version.

Conceptually:

```text
Current Version
      |
      v
Problem Detected
      |
      v
Select Previous Known-Good Version
      |
      v
Deploy Previous AMI
      |
      v
Validate
```

This allows failed application releases to be replaced with a known-good version.

---

## Repository Structure

```text
OTMS/
│
├── applications/
│   ├── frontend/
│   ├── employee-api/
│   ├── attendance-api/
│   ├── salary-api/
│   └── notification-api/
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

---

## Prerequisites

Before using the deployment pipeline, the required tooling and infrastructure access must be configured.

Typical requirements include:

* Git
* Jenkins
* AWS account
* AWS IAM permissions
* Terraform
* Ansible
* Packer
* AWS CLI
* Java
* Python
* Go
* Node.js / npm
* SonarQube
* Trivy
* Gitleaks
* OWASP ZAP where applicable

Exact versions should be maintained according to the project's tested toolchain.

---

## Deployment

The official deployment workflow is performed through Jenkins.

A typical deployment is:

```text
1. Commit application changes
2. Push changes to Git
3. Start Jenkins pipeline
4. Run application CI
5. Validate security and code quality
6. Create validated artifact
7. Build application AMI
8. Generate Terraform plan
9. Review/validate plan
10. Apply infrastructure
11. Configure hosts using Ansible
12. Deploy application
13. Execute smoke tests
14. Verify application health
```

---

## Destruction

Infrastructure must be destroyed through the controlled Jenkins/Terraform workflow.

Destructive operations should require explicit confirmation and should never be triggered accidentally as part of a normal deployment.

---

## Operational Validation

A deployment is considered successful only after:

* Infrastructure is available
* Application instances are healthy
* Required services are running
* Database connectivity is working
* Load balancer routing is working
* Application endpoints respond successfully
* Smoke tests pass

---

## Configuration and Secrets

Environment-specific values must not be hardcoded into the repository.

Sensitive values such as:

* AWS credentials
* database passwords
* API keys
* tokens
* SMTP credentials
* application secrets

must be provided through secure credential/configuration mechanisms.

---

## Project Goal

The goal of this repository is to provide a repeatable, automated, and traceable VM-based deployment platform for OTMS using established DevOps practices.

The complete lifecycle is:

```text
CODE
 ↓
CI
 ↓
SECURITY
 ↓
ARTIFACT
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
ROLLBACK / DESTROY
```
