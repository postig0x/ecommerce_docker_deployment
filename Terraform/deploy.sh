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

#     _         _           
#  __| |___  __| |_____ _ _ 
# / _` / _ \/ _| / / -_) '_|
# \__,_\___/\__|_\_\___|_|  

#               _                             _           
#  _ _  ___  __| |___   _____ ___ __  ___ _ _| |_ ___ _ _ 
# | ' \/ _ \/ _` / -_) / -_) \ / '_ \/ _ \ '_|  _/ -_) '_|
# |_||_\___/\__,_\___| \___/_\_\ .__/\___/_|  \__\___|_|  
#                              |_|                        