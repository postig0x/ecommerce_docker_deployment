#!/bin/bash
# deploy.sh

# log script output
exec > /home/ubuntu/user_data.log 2>&1

#             _                  _      _
#  __ ___  __| |___ _ _    _____| |_   | |_____ _  _
# / _/ _ \/ _` / _ \ ' \  (_-<_-< ' \  | / / -_) || |
# \__\___/\__,_\___/_||_| /__/__/_||_| |_\_\___|\_, |
#                                               |__/
# give codon access for workload grading
SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$SSH_PUBKEY" >> /home/ubuntu/.ssh/authorized_keys

#                _      _                    _             
#  _  _ _ __  __| |__ _| |_ ___   ____  _ __| |_ ___ _ __  
# | || | '_ \/ _` / _` |  _/ -_) (_-< || (_-<  _/ -_) '  \ 
#  \_,_| .__/\__,_\__,_|\__\___| /__/\_, /__/\__\___|_|_|_|
#      |_|                           |__/                  
# no upgrade for low disk use
sudo apt update

# install git, curl, wget
sudo apt install -y git curl wget

#               _                             _           
#  _ _  ___  __| |___   _____ ___ __  ___ _ _| |_ ___ _ _ 
# | ' \/ _ \/ _` / -_) / -_) \ / '_ \/ _ \ '_|  _/ -_) '_|
# |_||_\___/\__,_\___| \___/_\_\ .__/\___/_|  \__\___|_|  
#                              |_|                        
# version 1.8.2
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-*.*-amd64*

cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=ubuntu
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Node Exporter installation complete. Available on port :9100/metrics"

#     _         _           
#  __| |___  __| |_____ _ _ 
# / _` / _ \/ _| / / -_) '_|
# \__,_\___/\__|_\_\___|_|  
# get keyring, add repo and install
sudo apt update
sudo apt install -y ca-certificates
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
#post install
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# dockerhub auth
echo "${docker_pass}" | docker login --username "${docker_user}" --password-stdin

# clone docker-compose.yml code
mkdir app && cd app
cat > docker-compose.yml <<EOF
${docker_compose}
EOF

docker-compose pull
docker-compose up -d --force-recreate
echo "app deployed."

# clean and logout of dockerhub
docker system prune -f
docker logout
