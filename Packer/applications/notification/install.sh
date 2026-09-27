#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y python3 python3-venv

sudo mkdir -p /opt/otms/notification

sudo mv /tmp/application-artifact /opt/otms/notification/application.tar.gz

sudo tar -xzf /opt/otms/notification/application.tar.gz -C /opt/otms/notification

sudo python3 -m venv /opt/otms/notification/venv

if [ -f /opt/otms/notification/requirements.txt ]; then
    sudo /opt/otms/notification/venv/bin/pip install -r /opt/otms/notification/requirements.txt
fi

sudo useradd --system --no-create-home otms 2>/dev/null || true

sudo chown -R otms:otms /opt/otms/notification

sudo tee /etc/systemd/system/otms-notification.service > /dev/null <<EOF
[Unit]
Description=OTMS Notification API
After=network.target

[Service]
User=otms
WorkingDirectory=/opt/otms/notification
ExecStart=/opt/otms/notification/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable otms-notification.service
