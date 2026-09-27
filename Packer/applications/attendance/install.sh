#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y python3 python3-venv

sudo mkdir -p /opt/otms/attendance

sudo mv /tmp/application-artifact /opt/otms/attendance/application.tar.gz

sudo tar -xzf /opt/otms/attendance/application.tar.gz -C /opt/otms/attendance

sudo python3 -m venv /opt/otms/attendance/venv

if [ -f /opt/otms/attendance/requirements.txt ]; then
    sudo /opt/otms/attendance/venv/bin/pip install -r /opt/otms/attendance/requirements.txt
fi

sudo useradd --system --no-create-home otms 2>/dev/null || true

sudo chown -R otms:otms /opt/otms/attendance

sudo tee /etc/systemd/system/otms-attendance.service > /dev/null <<EOF
[Unit]
Description=OTMS Attendance API
After=network.target

[Service]
User=otms
WorkingDirectory=/opt/otms/attendance
ExecStart=/opt/otms/attendance/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable otms-attendance.service
