# OTMS Packer

This repository contains the Packer configuration used to create application AMIs for the OTMS project.

I used **Packer** to create immutable application images from artifacts produced by the application CI pipelines.

Packer is therefore part of the promotion flow between application CI and Terraform deployment.

---

## Packer Flow

The application artifact is produced first by the CI pipeline.

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

Packer does not build the application source code itself. It takes the validated artifact from CI, verifies it, installs it into an EC2-based image, and creates an AMI.

---

## Application AMIs

The project creates AMIs for the OTMS application components:

| Application      | Port |
| ---------------- | ---: |
| Frontend         | 3000 |
| Employee API     | 8080 |
| Attendance API   | 8081 |
| Salary API       | 8082 |
| Notification API | 8085 |

Each application has its own Packer build configuration and installation process.

---

## Artifact Verification

The Packer template accepts the following artifact information:

```text
Artifact
Artifact Manifest
Artifact SHA-256
Git SHA
Git Branch
CI Job
CI Build
```

Before the application is installed into the AMI, Packer verifies the artifact checksum.

```text
CI Artifact
     |
     v
SHA-256 Verification
     |
     +----> Failed → Packer build stops
     |
     v
Installation
     |
     v
Application AMI
```

This provides an additional check that the artifact being baked into the AMI is the expected artifact from the CI build.

---

## AMI Metadata

The generated AMI contains metadata through AWS tags.

Important information includes:

* Application name
* Git commit SHA
* Git branch
* Jenkins CI job
* Jenkins CI build number
* Artifact SHA-256
* Packer build information

The AMI name also contains the application name and shortened Git SHA.

For example:

```text
otms-employee-<git-sha>-<timestamp>
```

This makes the AMI easier to associate with the application version that produced it.

---

## Artifact Manifest

Along with the application artifact, Packer receives an artifact manifest.

The manifest is stored in the image under:

```text
/etc/otms/<application>-image-manifest.json
```

This allows deployment metadata to remain available on the application instance after the AMI has been created.

---

## Packer Template

The main reusable application Packer template is:

```text
applications/
└── application.pkr.hcl
```

The template receives application-specific values as variables rather than duplicating the complete Packer configuration for every service.

Important variables include:

```text
app_name
artifact_file
artifact_manifest_file
artifact_sha256
install_script
git_sha
git_branch
ci_job
ci_build
aws_region
packer_manifest_file
```

The AWS region used by the project is:

```text
us-east-1
```

---

## Installation Process

During the Packer build, the artifact, manifest, and installation script are copied to the temporary build instance.

The installation flow is:

```text
Packer Build Instance
        |
        +----> Application Artifact
        |
        +----> Artifact Manifest
        |
        +----> Installation Script
        |
        v
Checksum Verification
        |
        v
Application Installation
        |
        v
Manifest Stored
        |
        v
Temporary Files Removed
        |
        v
AMI Created
```

The temporary files used during the image build are removed after installation.

---

## Jenkins Integration

Packer builds are triggered through Jenkins.

The Packer pipeline receives the successful CI build number and uses the corresponding CI artifacts as the input for the AMI build.

The relationship is:

```text
OTMS/CI/Employee
        |
        | CI_BUILD_NUMBER
        v
OTMS/Packer/Employee
        |
        v
Employee AMI
```

The same pattern is used for the other application services.

This keeps the application CI build and the resulting AMI connected through the Jenkins build information.

---

## Packer Manifest

Packer also generates a build manifest containing information about the AMI created during the build.

The manifest provides a record of the Packer build and the resulting AMI.

This information can then be consumed by the deployment workflow when the AMI is promoted through Terraform.

---

## Why I Used Packer

I used Packer to avoid configuring the application from scratch every time an EC2 instance is launched.

Instead, the application is installed once while creating the AMI.

```text
Without Packer:

EC2
 |
 +--> Install dependencies
 +--> Download artif
```
