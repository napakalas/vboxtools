#!/bin/bash
# TODO automate the correct settings for this (e.g. symlink verified
# files to these locations)
export GENTOO_BOOT_ISO=./install-amd64-minimal.iso
export GENTOO_STAGE3=./stage3-amd64.tar.xz
export GENTOO_PORTAGE=./portage.tar.xz

export GENTOO_FILES=./gentoo_files

# spawn the vm using the common spawn script
export VBOX_NAME=gentoo_vm
export BOOT_ISO=$GENTOO_BOOT_ISO

# check that requried files are present and available.
for name in GENTOO_BOOT_ISO GENTOO_STAGE3 GENTOO_PORTAGE ; do
    if [ -z ${!name} ]; then
        echo "${name} is undefined; aborting"
        exit 1
    fi
    if [ ! -f ${!name} ]; then
        echo "${!name} is missing in working directory; aborting"
        exit 1
    fi
done

# include the spawn script
# TODO name these things properly
. ./spawn.sh

create_vm

if [ $? -ne 0 ]; then
    echo "failed to create vm ${VBOX_NAME} for gentoo build"
    exit 1
fi

start_vm

# hit enter a couple times
# first to boot from the iso.
sleep 5
runscancode ""
# then to select default keyboard layout.
sleep 10
runscancode ""

echo "sleeping for 20 seconds before working"
sleep 20

# get the guest to talk to the host to populate the arp table
runscancode "ping -c1 $VBOX_HOST_IP"

set_vm_mac_ip $VBOX_NAME $VBOX_NET
if [ $? -ne 0 ]; then
    echo "failed to derive IP, cannot continue with automated installation"
    exit 1
fi

# run everything in a screen session
runscancode "screen"
runscancode "/etc/init.d/sshd start"
runscancode "mkdir ~/.ssh"
runscancode "echo $(cat $VBOX_PUBKEY) > ~/.ssh/authorized_keys"

scp -oStrictHostKeyChecking=no -oBatchMode=Yes -i $VBOX_PRIVKEY \
    $GENTOO_STAGE3 root@$VBOX_IP:stage3-amd64.tar

scp -oStrictHostKeyChecking=no -oBatchMode=Yes -i $VBOX_PRIVKEY \
    $GENTOO_PORTAGE root@$VBOX_IP:portage.tar

rsync -re "ssh -oStrictHostKeyChecking=no -oBatchMode=Yes -i $VBOX_PRIVKEY" \
    $GENTOO_FILES/ root@$VBOX_IP:gentoo_files

# pass that as a stuff directly into the screen session
ssh -oStrictHostKeyChecking=no -oBatchMode=Yes -i $VBOX_PRIVKEY root@$VBOX_IP \
    "screen -p 0 -X stuff './gentoo_files/init.sh^m'"
