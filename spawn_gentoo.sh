#!/bin/bash
# TODO automate the correct settings for this (e.g. symlink verified
# files to these locations)
export GENTOO_BOOT_ISO=install-amd64-minimal.iso
export GENTOO_STAGE3=stage3-amd64.tar.xz
export GENTOO_PORTAGE=snapshot.tar.gz

# spawn the vm using the common spawn script
export VBOX_NAME=gentoo_vm
export BOOT_ISO=$GENTOO_BOOT_ISO

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
VBoxManage controlvm $VBOX_NAME keyboardputscancode 1c 9c
# then to select default keyboard layout.
sleep 10
VBoxManage controlvm $VBOX_NAME keyboardputscancode 1c 9c

echo "sleeping for 20 seconds before working"
sleep 20

# get the guest to talk to the host to populate the arp table
runscancode "ping -c1 $VBOX_HOST_IP"

VBOX_MAC=$(
    VBoxManage showvminfo ${VBOX_NAME} | grep ${VBOX_NET} | \
    sed -r 's/.*MAC: ([0-9A-F]*).*/\1/' | sed -r 's/(.{2})/:\1/g' | cut -b 2-
)

echo "mac is $VBOX_MAC"

VBOX_IP=$(
    arp | grep -i ${VBOX_MAC} | cut -d' ' -f1
)

if [ -z $VBOX_IP ]; then
    echo "failed to derive IP, cannot continue with automated installation"
    exit 1
fi

echo "ip is $VBOX_IP"

# run everything in a screen session
runscancode "screen"
runscancode "/etc/init.d/sshd start"
runscancode "mkdir .ssh"
runscancode "echo $(cat $VBOX_PUBKEY) > ~/.ssh/authorized_keys"

# just shut the vm down immediately for now
ssh -oStrictHostKeyChecking=no -oBatchMode=Yes -i $VBOX_PRIVKEY root@$VBOX_IP \
    screen -p 0 -X stuff "'shutdown -h now^M'"
