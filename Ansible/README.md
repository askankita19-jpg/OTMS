# OTMS Ansible

This repository contains the Ansible configuration used for the OTMS project.

I used Ansible for configuring the database servers after the AWS infrastructure is provisioned by Terraform.

The database configuration is separated into three Ansible roles:

* PostgreSQL
* Redis
* ScyllaDB

---

## Ansible Structure

```text
Ansible/
│
├── ci/
│   ├── inventory/
│   │   └── localhost.ini
│   ├── playbooks/
│   │   ├── postgresql.yml
│   │   ├── redis.yml
│   │   └── scylladb.yml
│   └── requirements-ci.txt
│
├── cd/
│   ├── playbooks/
│   │   └── databases.yml
│   └── requirements-cd.txt
│
├── roles/
│   ├── postgresql/
│   ├── redis/
│   └── scylladb/
│
├── collections/
│   └── requirements.yml
│
├── ansible.cfg
├── .ansible-lint
├── .yamllint
└── README.md
```

---

## Role Responsibilities

### PostgreSQL

The PostgreSQL role installs and configures PostgreSQL for the OTMS Attendance API.

It also creates the required database and schema used by the Attendance service.

The role includes configuration, service management, database setup, and verification tasks.

### Redis

The Redis role installs and configures Redis as the caching layer used by the OTMS application.

Redis is used by the Employee, Attendance, and Salary services.

### ScyllaDB

The ScyllaDB role installs and configures ScyllaDB for the OTMS application.

It creates the required keyspace and tables used by the Employee and Salary services.

---

## CI and CD

I separated Ansible validation from the actual database configuration.

### Ansible CI

Ansible CI validates the roles and playbooks before they are used for deployment.

The CI flow includes:

```text
Checkout
   |
   v
Dependency Installation
   |
   v
YAML Validation
   |
   v
Ansible Syntax Check
   |
   v
Ansible Lint
   |
   v
Security Checks
```

The CI configuration uses pinned versions of Ansible and the required Ansible collections.

### Ansible CD

Ansible CD configures the database instances created by Terraform.

The deployment flow is:

```text
Terraform
   |
   v
Database EC2 Instances
   |
   v
AWS Systems Manager
   |
   v
Ansible
   |
   +------------------+
   |        |         |
   v        v         v
PostgreSQL Redis   ScyllaDB
```

---

## AWS Systems Manager Integration

The database instances are private EC2 instances and are managed through **AWS Systems Manager (SSM)**.

Ansible CD uses the `amazon.aws.aws_ssm` connection plugin to communicate with the instances.

This means the deployment does not depend on:

* Public IP addresses
* Inbound SSH access
* SSH keys

The connection path is:

```text
Jenkins
   |
   v
AWS API
   |
   v
Systems Manager
   |
   v
SSM Agent
   |
   v
Private EC2 Instance
```

Ansible then executes the required configuration tasks on the database hosts.

---

## Database Configuration Flow

The main CD playbook is:

```text
cd/playbooks/databases.yml
```

It applies the three database roles:

```text
databases.yml
      |
      +----> postgresql role
      |
      +----> redis role
      |
      +----> scylladb role
```

The PostgreSQL configuration receives its protected password through the CI/CD credential environment rather than storing the password directly in the Ansible repository.

---

## Ansible Collections

The project uses the following Ansible collections:

```text
amazon.aws
community.postgresql
```

The collection versions are pinned in:

```text
collections/requirements.yml
```

This helps keep the Ansible controller environment consistent between runs.

---

## Configuration Management Approach

I used Ansible roles so that each database has its own configuration logic.

This keeps the database configuration separated and makes the individual roles easier to test and maintain.

The roles are designed to be **idempotent**, so running the same configuration again should converge the server towards the required state rather than repeatedly creating the same resources.

---

## Overall Flow

The Ansible part of the OTMS deployment fits into the larger deployment lifecycle as follows:

```text
Application CI
      |
      v
Packer
      |
      v
Terraform
      |
      v
AWS Infrastructure
      |
      v
Database EC2 Instances
      |
      v
AWS SSM
      |
      v
Ansible
      |
      +-------------------+
      |         |         |
      v         v         v
 PostgreSQL   Redis   ScyllaDB
      |
      v
Application Deployment
```

Ansible therefore acts as the configuration-management layer between infrastructure provisioning and the application deployment.
