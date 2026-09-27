#!/bin/bash

set -e

sudo mkdir -p /opt/otms/employee

sudo mv /tmp/application-artifact /opt/otms/employee/employee-api

sudo chmod +x /opt/otms/employee/employee-api

sudo useradd --system --no-create-home otms 2>/dev/null || true

sudo chown -R otms:otms /opt/otms/employee

sudo tee /etc/systemd/system/otms-employee.service > /dev/null <<EOF
[Unit]
Description=OTMS Employee API
After=network.target

[Service]
User=otms
WorkingDirectory=/opt/otms/employee
ExecStart=/opt/otms/employee/employee-api
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable otms-employee.service
