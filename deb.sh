#!/bin/sh


# Declare Paths
SYS_PATH="/etc/sysctl.conf"
LIM_PATH="/etc/security/limits.conf"
PROF_PATH="/etc/profile"
SSH_PATH="/etc/ssh/sshd_config"
DNS_PATH="/etc/resolv.conf"


# Check Root User
check_if_running_as_root() {

  # If you want to run as another user, please modify $EUID to be owned by this user
  if [[ "$EUID" -ne '0' ]]; then
    echo "$(tput setaf 1)Error: You must run this script as root!$(tput sgr0)"
    exit 1
  fi
}


# Check if OS is Debian
check_debian() {
  if [[ $(lsb_release -si) != "Debian" ]]; then
    echo "$(tput setaf 1)Error: This script is only intended to run on Debian.$(tput sgr0)"
    exit 1
  fi
}


# Fix DNS
fix_dns() {
  echo 
  echo "$(tput setaf 3)----- Optimizing System DNS Settings.$(tput sgr0)"
  echo 
  sleep 1

  sed -i '/nameserver/d' $DNS_PATH

  echo 'nameserver 1.1.1.1' >> $DNS_PATH
  echo 'nameserver 1.0.0.1' >> $DNS_PATH
  echo 'nameserver 8.8.8.8' >> $DNS_PATH
  echo 'nameserver 8.8.4.4' >> $DNS_PATH
  
  echo 
  echo "$(tput setaf 2)----- System DNS Optimized.$(tput sgr0)"
  echo
  sleep 1
}


# Update & Upgrade & Remove & Clean
complete_update() {
  echo 
  echo "$(tput setaf 3)----- Updating the System.$(tput sgr0)"
  echo 
  sleep 1

  sudo apt update
  sudo apt -y upgrade
  sleep 0.5
  sudo apt -y dist-upgrade
  sudo apt -y autoremove
  sudo apt -y autoclean
  sudo apt -y clean
  echo 
  echo "$(tput setaf 2)----- System Updated Successfully.$(tput sgr0)"
  echo 
  sleep 1
}


## Install useful packages
installations() {
  echo 
  echo "$(tput setaf 3)----- Installing Useful Packeges.$(tput sgr0)"
  echo 
  sleep 1

  # Purge firewalld to install UFW.
  sudo apt -y purge firewalld

  # Install
  sudo apt -y install ca-certificates apt-utils cron bash-completion 
  sudo apt -y install curl git wget preload locales socat
  sleep 0.5
  echo 
  echo "$(tput setaf 2)----- Useful Packages Installed Succesfully.$(tput sgr0)"
  echo 
  sleep 0.5
}


# Enable packages at server boot
enable_packages() {
  sudo systemctl enable preload cron
  echo 
  echo "$(tput setaf 2)----- Packages Enabled Succesfully.$(tput sgr0)"
  echo
  sleep 0.5
}


## Swap Maker
swap_maker() {
  echo 
  echo "$(tput setaf 3)----- Making SWAP Space.$(tput sgr0)"
  echo 
  sleep 1

  # 2 GB Swap Size
  SWAP_SIZE=2G

  # Default Swap Path
  SWAP_PATH="/swapfile"

  # Make Swap
  sudo fallocate -l $SWAP_SIZE $SWAP_PATH  # Allocate size
  sudo chmod 600 $SWAP_PATH                # Set proper permission
  sudo mkswap $SWAP_PATH                   # Setup swap         
  sudo swapon $SWAP_PATH                   # Enable swap
  echo "$SWAP_PATH   none    swap    sw    0   0" >> /etc/fstab # Add to fstab
  echo 
  echo $(tput setaf 2)----- SWAP Created Successfully.$(tput sgr0)
  echo
  sleep 0.5
  
}
