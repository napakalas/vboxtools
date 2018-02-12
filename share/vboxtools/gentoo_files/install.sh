#!/bin/bash
set -e
source /etc/profile
emerge --update --deep --newuse @world
emerge app-admin/syslog-ng app-portage/gentoolkit net-misc/dhcpcd \
    sys-apps/mlocate sys-block/parted sys-boot/grub:2 \
    sys-kernel/genkernel-next sys-kernel/gentoo-sources sys-process/cronie \
    dev-vcs/git sys-power/acpid
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
echo UTC >> /etc/timezone
emerge --config sys-libs/timezone-data
source /etc/profile
mv /.config /usr/src/linux/.config
genkernel --oldconfig --no-zfs --no-btrfs all
echo -e "$(blkid | grep sda2 | cut -f2 -d\ )\t\t/\t\text4\trw,noatime\t0 1" \
    >> /etc/fstab
ln -s net.lo /etc/init.d/net.eth0
ln -s net.lo /etc/init.d/net.eth1
rc-update add acpid default
rc-update add net.eth0 default
rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default
echo PermitRootLogin prohibit-password >> /etc/ssh/sshd_config

cat << EOF >> /etc/default/grub
GRUB_TIMEOUT=2
GRUB_CMDLINE_LINUX="net.ifnames=0"
EOF

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo "completing installation, removing installation script"
/bin/rm /install.sh
