#!/bin/bash
# change these settings to a more suitable form

# TODO should import/declare these from a separate script
# export BOOT_ISO=
# export VBOX_NAME=
export VBOX_ROOT=$HOME/vm
export VBOX_DISK_SIZE=10000
export VBOX_N_CPU=4

# standard settings, modify with care
export VBOX_HOME=$VBOX_ROOT/$VBOX_NAME
export VBOX_IMG=$VBOX_HOME/$VBOX_NAME.vhd
export VBOX_PRIVKEY=$VBOX_HOME/id_rsa
export VBOX_PUBKEY=$VBOX_HOME/id_rsa.pub
export VBOX_NET=vboxnet0

for name in BOOT_ISO VBOX_NAME; do
    if [ -z ${!name} ]; then
        echo "${name} is undefined"
        exit 1
    fi
done

# verify that the vm and image does not already exists yet
VBoxManage showvminfo $VBOX_NAME 2>/dev/null >/dev/null
if [ $? -eq 0 ]; then
    echo "'${VBOX_NAME}' is already registered as a vm"
    echo "(unregister with: VBoxManage unregistervm '${VBOX_NAME}')"
    exit 1
fi

if [ -f "${VBOX_IMG}" ]; then
    echo "vm image at '${VBOX_IMG}' already exists"
    exit 1
fi

# automatically create vboxnet0 if not exists
VBoxManage list hostonlyifs |grep vboxnet0 2> /dev/null >/dev/null
if [ $? -ne 0 ]; then
    VBoxManage hostonlyif create
fi

# find the existence of the target vboxnet, which may not be present
# (this is the reason for sticking with default $VBOX_NET)
VBoxManage list hostonlyifs |grep $VBOX_NET 2> /dev/null >/dev/null
if [ $? -ne 0 ]; then
    echo "hostonlyif ${VBOX_NET} does not exist"
    exit 1
fi

# create the VM

mkdir -p $VBOX_ROOT
VBoxManage createvm --name $VBOX_NAME --basefolder $VBOX_ROOT --register
VBoxManage modifyvm $VBOX_NAME --ostype Gentoo_64 --memory=4096 \
    --nic1 hostonly --nic2 nat --cableconnected1 on --cableconnected2 on \
    --nictype1 82540EM --nictype2 82540EM --hostonlyadapter1 $VBOX_NET

VBoxManage storagectl $VBOX_NAME --name IDE --add ide --controller PIIX4
VBoxManage storagectl $VBOX_NAME --name SATA --add sata \
    --controller IntelAhci

VBoxManage createmedium disk --size $VBOX_DISK_SIZE --format VHD \
    --filename $VBOX_IMG

VBoxManage storageattach $VBOX_NAME --storagectl IDE --port 0 --device 0 \
    --type dvddrive --medium $BOOT_ISO
VBoxManage storageattach $VBOX_NAME --storagectl SATA --port 0 --device 0 \
    --type hdd --medium $VBOX_IMG

# boot VM
VBoxManage startvm $VBOX_NAME
