#!/usr/bin/env bash

#language
sudo locale-gen "en_US.UTF-8"
sudo sh -c "echo >> /etc/environment"
sudo sh -c "echo LC_ALL=en_US.UTF-8 >> /etc/environment"
sudo sh -c "echo LANG=en_US.UTF-8>> /etc/environment"

#swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bkp_before_swap_config
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
sudo sh -c "echo 'vm.swappiness=1' >> /etc/sysctl.conf"

# updates
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y


#!/bin/bash
echo Installing docker...
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker

#status of docker
echo You can check status of docker service with:
echo sudo systemctl status docker

#add current user to docker group to use without sudo
echo "Adding current user to docker group. You have to relog to make this work"
sudo usermod -aG docker $USER

echo "Installing docker-compose"
sudo sh -c 'sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
sudo chmod +x /usr/local/bin/docker-compose

echo "Changing storage driver to devicemapper"
sudo systemctl stop docker
sudo rm -rf /var/lib/docker
sudo sed -i -e '/^ExecStart=/ s/$/ --storage-driver=overlay2/' /lib/systemd/system/docker.service

echo "Reloading services"
sudo systemctl daemon-reload
sudo service docker restart
sudo systemctl restart docker

echo "Current storage driver is: (be worried if its not storage driver)"
sudo docker info | grep Storage\ Driver
