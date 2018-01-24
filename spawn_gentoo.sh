#!/bin/bash
# edit as required
# TODO automate the correct settings of this
export GENTOO_BOOT_ISO=install-amd64-minimal.iso
export GENTOO_STAGE3=stage3-amd64.tar.xz

# spawn the vm using the common spawn script
export VBOX_NAME=gentoo_vm
export BOOT_ISO=$GENTOO_BOOT_ISO
./spawn.sh

if [ $? -ne 0 ]; then
    echo "failed to spawn ${VBOX_NAME} for gentoo build"
    exit 1
fi

# hit enter a couple times
# to boot from the iso.
sleep 5
VBoxManage controlvm $VBOX_NAME keyboardputscancode 1c 9c
# select default keyboard layout
sleep 10
VBoxManage controlvm $VBOX_NAME keyboardputscancode 1c 9c
