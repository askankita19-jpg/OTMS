# OTMS Job DSL

This directory contains the Jenkins Job DSL configuration for creating OTMS application jobs.

## Applications

The Job DSL creates Jenkins pipeline jobs for:

- OTMS Frontend
- OTMS Employee API
- OTMS Attendance API
- OTMS Salary API
- OTMS Notification

## Architecture

```text
Application Data
       |
       v
    Job DSL
       |
       v
   Seed Job
       |
       v
+----------------------+
| Jenkins Jobs         |
+----------------------+
| otms-frontend        |
| otms-employee-api    |
| otms-attendance-api  |
| otms-salary-api      |
| otms-notification    |
+----------------------+
Benefits

The Job DSL provides a repeatable way to create and manage Jenkins jobs as code.

Application-specific values are represented as data, allowing the same job definition to be reused for multiple applications.


---

# What we've achieved

Our Jenkins architecture is now becoming:

```text
                    Jenkins
                       |
             ┌─────────┴─────────┐
             |                   |
       Shared Library          Job DSL
             |                   |
             |                Seed Job
             |                   |
             |          ┌────────┼────────┐
             |          ↓        ↓        ↓
             |       Frontend Employee  Salary
             |       Attendance Notification
             |
             ↓
       Common CI logic
