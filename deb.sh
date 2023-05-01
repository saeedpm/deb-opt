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


# Remove Old SYSCTL Config to prevent duplicates.
remove_old_sysctl() {
  sed -i '/fs.file-max/d' $SYS_PATH
  sed -i '/fs.inotify.max_user_instances/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syncookies/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_fin_timeout/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_tw_reuse/d' $SYS_PATH
  sed -i '/net.ipv4.ip_local_port_range/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' $SYS_PATH
  sed -i '/net.ipv4.route.gc_timeout/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syn_retries/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_synack_retries/d' $SYS_PATH
  sed -i '/net.core.somaxconn/d' $SYS_PATH
  sed -i '/net.core.netdev_max_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_timestamps/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_orphans/d' $SYS_PATH
  sed -i '/net.ipv4.ip_forward/d' $SYS_PATH

  #IPv6
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.all.forwarding/d' $SYS_PATH
  # System Limits.

  sed -i '/soft/d' $LIM_PATH
  sed -i '/hard/d' $LIM_PATH

  # BBR
  sed -i '/net.core.default_qdisc/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_congestion_control/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_ecn/d' $SYS_PATH

  # uLimit
  sed -i '/1000000/d' $PROF_PATH

  #SWAP
  sed -i '/vm.swappiness/d' $SYS_PATH
  sed -i '/vm.vfs_cache_pressure/d' $SYS_PATH
}


## SYSCTL Optimization
sysctl_optimizations() {
  echo 
  echo "$(tput setaf 3)----- Optimizing the Network.$(tput sgr0)"
  echo 
  sleep 1

  # Optimize Swap Settings
  echo 'vm.swappiness=10' >> $SYS_PATH
  echo 'vm.vfs_cache_pressure=50' >> $SYS_PATH
  sleep 0.5

  # Optimize Network Settings
  echo 'fs.file-max = 1000000' >> $SYS_PATH

  echo 'net.core.rmem_default = 1048576' >> $SYS_PATH
  echo 'net.core.rmem_max = 2097152' >> $SYS_PATH
  echo 'net.core.wmem_default = 1048576' >> $SYS_PATH
  echo 'net.core.wmem_max = 2097152' >> $SYS_PATH
  echo 'net.core.netdev_max_backlog = 16384' >> $SYS_PATH
  echo 'net.core.somaxconn = 32768' >> $SYS_PATH
  echo 'net.ipv4.tcp_fastopen = 3' >> $SYS_PATH
  echo 'net.ipv4.tcp_mtu_probing = 1' >> $SYS_PATH

  echo 'net.ipv4.tcp_retries2 = 8' >> $SYS_PATH
  echo 'net.ipv4.tcp_slow_start_after_idle = 0' >> $SYS_PATH
  echo 'net.ipv4.ip_forward = 1' | tee -a $SYS_PATH

  echo 'net.ipv6.conf.all.disable_ipv6 = 0' >> $SYS_PATH
  echo 'net.ipv6.conf.default.disable_ipv6 = 0' >> $SYS_PATH
  echo 'net.ipv6.conf.all.forwarding = 1' >> $SYS_PATH

  # Use BBR
  echo 'net.core.default_qdisc = fq' >> $SYS_PATH 
  echo 'net.ipv4.tcp_congestion_control = bbr' >> $SYS_PATH

  sysctl -p
  echo 
  echo $(tput setaf 2)----- Network is Optimized.$(tput sgr0)
  echo 
  sleep 0.5
}
