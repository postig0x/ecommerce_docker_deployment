#!/bin/bash
# jenkins.sh

sudo apt update

sudo apt install -y fontconfig openjdk-17-jre software-properties-common

# jenkins keyring
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# jenkins repo
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
        https://pkg.jenkins.io/debian-stable binary/ | \
        sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update

# install jenkins
sudo apt install -y jenkins

# start + enable daemon
sudo systemctl start jenkins

sudo systemctl enable jenkins

# verify
sudo systemctl status jenkins
