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
