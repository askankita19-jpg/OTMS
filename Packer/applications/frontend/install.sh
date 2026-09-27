#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y nodejs npm

sudo mkdir -p /opt/otms/frontend

sudo mv /tmp/application-artifact /opt/otms/frontend/application.tar.gz

sudo tar -xzf /opt/otms/frontend/application.tar.gz -C /opt/otms/frontend

cd /opt/otms/frontend

if [ -f package.json ]; then
    sudo npm install
    sudo npm run build
fi

sudo useradd --system --no-create-home otms 2>/dev/null || true

sudo chown -R otms:otms /opt/otms/frontend

sudo tee /etc/systemd/system/otms-frontend.service > /dev/null <<EOF
[Unit]
Description=OTMS Frontend
After=network.target

[Service]
User=otms
WorkingDirectory=/opt/otms/frontend
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable otms-frontend.service
