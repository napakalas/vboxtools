#!/bin/bash
# change these settings to a more suitable form

. ./env.sh

putscancode () {
    echo $@ | python scancode.py
}

runscancode () {
    putscancode $@ | xargs -n $VBOX_SCANCODE_LIMIT \
        VBoxManage controlvm $VBOX_NAME keyboardputscancode
}

set_vm_mac_ip () {
    name=$1
    net=$2
    VBOX_MAC=$(
        VBoxManage showvminfo ${name} | grep ${net} | \
        sed -r 's/.*MAC: ([0-9A-F]*).*/\1/' | sed -r 's/(.{2})/:\1/g' | \
        cut -b 2-
    )
    echo "mac is $VBOX_MAC"
    VBOX_IP=$(
        arp | grep -i ${VBOX_MAC} | cut -d' ' -f1
    )
    if [ -z $VBOX_IP ]; then
        echo "failed to derive IP, cannot continue with automated installation"
        false
        return
    fi
    echo "ip is $VBOX_IP"
    export VBOX_MAC=$VBOX_MAC
    export VBOX_IP=$VBOX_IP
}

# don't provide the vm functions until things are defined
for name in BOOT_ISO VBOX_NAME; do
    if [ -z ${!name} ]; then
        echo "${name} is undefined"
        false
        return
    fi
done

create_vm () {
    # standard settings, modify with care
    export VBOX_HOME=$VBOX_ROOT/$VBOX_NAME
    export VBOX_IMG=$VBOX_HOME/$VBOX_NAME.vhd
    export VBOX_PRIVKEY=$VBOX_HOME/id_rsa
    export VBOX_PUBKEY=$VBOX_HOME/id_rsa.pub
    export VBOX_NET=vboxnet0

    # verify that the vm and image does not already exists yet
    VBoxManage showvminfo $VBOX_NAME 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
        echo "'${VBOX_NAME}' is already registered as a vm"
        echo "(unregister with: VBoxManage unregistervm '${VBOX_NAME}')"
        false
        return
    fi

    if [ -f "${VBOX_IMG}" ]; then
        echo "vm image at '${VBOX_IMG}' already exists"
        false
        return
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
        false
        return
    fi

    export VBOX_HOST_IP=$(
        VBoxManage list hostonlyifs |grep ${VBOX_NET} -A4 | \
        grep IPAddress| awk '{print $2}'
    )

    # create the VM

    mkdir -p $VBOX_ROOT
    VBoxManage createvm --name $VBOX_NAME --basefolder $VBOX_ROOT --register
    VBoxManage modifyvm $VBOX_NAME --ostype Gentoo_64 --memory=4096 \
        --cpus $VBOX_N_CPU --ioapic on \
        --nic1 hostonly --nic2 nat --cableconnected1 on --cableconnected2 on \
        --nictype1 82540EM --nictype2 82540EM --hostonlyadapter1 $VBOX_NET

    VBoxManage storagectl $VBOX_NAME --name IDE --add ide --controller PIIX4
    VBoxManage storagectl $VBOX_NAME --name SATA --add sata \
        --controller IntelAhci --portcount 4

    VBoxManage createmedium disk --size $VBOX_DISK_SIZE --format VHD \
        --filename $VBOX_IMG

    VBoxManage storageattach $VBOX_NAME --storagectl IDE --port 0 --device 0 \
        --type dvddrive --medium $BOOT_ISO
    VBoxManage storageattach $VBOX_NAME --storagectl SATA --port 0 --device 0 \
        --type hdd --medium $VBOX_IMG

    # generate ssh keys
    ssh-keygen -N '' -f $VBOX_PRIVKEY
}


start_vm () {
    # boot VM
    VBoxManage startvm $VBOX_NAME
}
