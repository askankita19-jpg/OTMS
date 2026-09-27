# OTMS Job DSL

This repository contains the Jenkins Job DSL implementation used in the OTMS project.

I used **Jenkins Job DSL** to define the Jenkins jobs as code instead of creating each job manually from the Jenkins UI.

## Job Structure

The Job DSL creates Jenkins jobs under the `OTMS` folder.

```text
OTMS/
│
├── CI/
│   ├── Attendance
│   ├── Employee
│   ├── Frontend
│   ├── Notification
│   ├── Salary
│   └── Terraform
│
├── Packer/
│   ├── Attendance
│   ├── Employee
│   ├── Frontend
│   ├── Notification
│   └── Salary
│
├── Ansible-CI/
│   ├── PostgreSQL
│   ├── Redis
│   └── ScyllaDB
│
├── CD/
│   ├── Terraform
│   ├── Terraform-Destroy
│   └── Ansible
│
└── Master/
```

## Implementation

The Job DSL is maintained in:

```text
jobs/
└── otms.groovy
```

The `otms.groovy` file defines the Jenkins folders and pipeline jobs along with their parameters, SCM configuration, pipeline script paths, build retention settings, and artifact permissions.

For repeated job patterns, I used Groovy iteration instead of writing the same Job DSL definition multiple times.

For example, the five application Packer jobs are generated from a single definition:

```text
Attendance
Notification
Salary
Employee
Frontend
```

This keeps the Job DSL easier to maintain when the same job structure is required for multiple applications.

## Jenkins Pipeline Integration

The Job DSL does not contain the complete CI/CD pipeline logic.

Instead, it creates Jenkins jobs that point to the corresponding Jenkinsfiles.

For example:

```text
Job DSL
   |
   v
OTMS/CI/Employee
   |
   v
CI_Pipelines/Employee/Jenkinsfile
```

Similarly, the Packer, Terraform, Ansible, and Master jobs point to their respective Jenkinsfiles.

This keeps **job creation** separate from **pipeline implementation**.

## Purpose

The main purpose of this implementation is to make Jenkins job creation repeatable and manageable through code.

If the Jenkins environment needs to be recreated, the Job DSL can be executed again to recreate the OTMS job structure instead of manually creating every job.
