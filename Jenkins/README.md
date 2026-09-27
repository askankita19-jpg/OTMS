# OTMS Jenkins

This directory contains the Jenkins CI pipeline used for the OTMS project.

## Pipeline

The pipeline performs:

1. Source checkout
2. Secret scanning with Gitleaks
3. Application build
4. Application testing
5. Filesystem security scanning with Trivy
6. Artifact packaging
7. Artifact archiving

## Structure

```text
Jenkins/
├── Jenkinsfile
├── README.md
└── scripts/
    ├── build.sh
    ├── test.sh
    └── package.sh
Security Tools
Tool	Purpose
Gitleaks	Secret detection
Trivy	Security and vulnerability scanning
SonarQube	Static code analysis
Artifact

The pipeline produces:

artifacts/
├── otms-application-<version>.tar.gz
├── otms-application-<version>.sha256
└── artifact-manifest.json

The artifact and checksum provide the input for the later Packer stage.


---

## But there's an important architectural change

I don't want us to keep this as a generic `otms-application` pipeline.

Your actual project has **five application repositories**:

```text
OTMS-Frontend
OTMS-Employee-API
OTMS-Attendance-API
OTMS-Salary-API
OTMS-Notification

Their build commands and test commands are different because they use different technologies.

So the next Jenkins step should be to make the pipeline application-aware:

                  Jenkins
                     │
        ┌────────────┼────────────┐
        ↓            ↓            ↓
     Frontend     Employee      Salary
      Node.js        Go          Java
        │            │            │
        └────────────┼────────────┘
                     ↓
               Common Pipeline
                     ↓
          Security + Artifact

Then we'll introduce the Shared Library, so we don't maintain five copies of the same Jenkins pipeline.

Our remaining Jenkins work
🔵 Jenkins CI              ← now
   ↓
🔵 Application-specific CI
   ↓
🔵 Shared Library
   ↓
🔵 Job DSL
   ↓
🔵 Seed Job
   ↓
🔵 Master Pipeline
   ↓
🔵 Jenkins → Packer → Terraform → Ansible
