# Dual root 
Modified version of [alpine-make-vm-image](https://github.com/alpinelinux/alpine-make-vm-image) which generates UEFI bootable, dual root fs (active and passive) disk image.


Additionally user can choose "read-only" mode which enables [overlayed tmpfs](https://wiki.alpinelinux.org/wiki/Raspberry_Pi) on top of root file system which changes which will be discarded on shutdown.


For demostration purposes first root partition contains Docker and second K3s:
![alt text](https://raw.githubusercontent.com/olljanat/alpine-make-vm-image/rootfs-only/screenshot.png "Grub")
