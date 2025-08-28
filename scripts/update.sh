# mount the bootloader in case we update the kernel
sudo mount /dev/nvme0n1p1 /boot
sudo pacman -Syu linux-firmware

