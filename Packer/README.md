# OTMS Packer

This directory contains the Packer configuration used to create application AMIs for the OTMS VM deployment model.

## Applications

| Application | Runtime | Port |
|---|---|---:|
| Frontend | Node.js | 3000 |
| Employee API | Go | 8080 |
| Attendance API | Python | 8081 |
| Salary API | Java | 8082 |
| Notification API | Python | 8085 |

## Structure

```text
Packer/
├── applications/
│   ├── application.pkr.hcl
│   ├── employee/
│   │   └── install.sh
│   ├── attendance/
│   │   └── install.sh
│   ├── salary/
│   │   └── install.sh
│   ├── notification/
│   │   └── install.sh
│   └── frontend/
│       └── install.sh
└── README.md
