#!/bin/bash
parted --script /dev/sda \
    mklabel gpt \
    mkpart primary 0 1MB \
    mkpart primary 1MB 100% \
    set 1 bios_grub on

mkfs.ext4 /dev/sda2
mkdir -p /mnt/gentoo
mount /dev/sda2 /mnt/gentoo
echo "extracting stage3"
tar xpf stage3-amd64.tar --xattrs-include='*.*' --numeric-owner \
    -C /mnt/gentoo
echo "extracting portage"
tar xpf portage.tar --numeric-owner -C /mnt/gentoo/usr
mount -t proc proc /mnt/gentoo/proc
mount -R /dev /mnt/gentoo/dev
mount -R /sys /mnt/gentoo/sys
echo "syncing extra files"
rsync -av ~/gentoo_files/root/ /mnt/gentoo/
cp -L /etc/resolv.conf /mnt/gentoo/etc/
cp -a /root/.ssh /mnt/gentoo/root/
cp ~/gentoo_files/install.sh /mnt/gentoo
echo "entering chroot"
chroot /mnt/gentoo /bin/bash /install.sh ; umount -R /mnt/gentoo ; halt
