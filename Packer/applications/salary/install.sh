#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y openjdk-17-jre

sudo mkdir -p /opt/otms/salary

sudo mv /tmp/application-artifact /opt/otms/salary/salary-api.jar

sudo useradd --system --no-create-home otms 2>/dev/null || true

sudo chown -R otms:otms /opt/otms/salary

sudo tee /etc/systemd/system/otms-salary.service > /dev/null <<EOF
[Unit]
Description=OTMS Salary API
After=network.target

[Service]
User=otms
WorkingDirectory=/opt/otms/salary
ExecStart=/usr/bin/java -jar /opt/otms/salary/salary-api.jar
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable otms-salary.service
