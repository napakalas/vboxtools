# vboxtools: VirtualBox tools

A set of tools for spinning up VirtualBox VMs from scratch

This is still very much a work in progress at the moment.  The goal of
this package is to provide a set of scripts that will produce a working
VirtualBox VM from various installation media, and also to assist with
automating certain tasks with the management of these VMs.

The default set of scripts make use of [Gentoo](https://gentoo.org/) as
the base distribution.  Scripts for creation of images of other
distributions depend on this base bootable VM, as this provides the most
basic yet flexible base system to spawn other bootable disk images.


## Installation

Simply git clone this repo.

### Enable automatic verification of downloaded installation media

To ensure that the binary files downloaded from the Gentoo servers are
not tempered with, please also ensure that [GnuPG](https://gnupg.org/)
is available on the system, and add the appropriate keys provided by
Gentoo on their [listing of release media signatures](https://www.gentoo.org/downloads/signatures/).
Please consult that page for the most up to date information regarding
the Key ID and Fingerprint for the following required keys:

    Gentoo Linux Release Engineering (Automated Weekly Release Key)
    - 0xBB572E0E2D182910
    Gentoo Portage Snapshot Signing Key (Automated Signing Key)
    - 0xDB6B8C1F96D8BF6D

Instructions on how the keys are added to the keyring is done is
outlined in the [Gentoo Installation Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media#Linux_based_verification).
For convenience, the following commands will add the appropriate keys
to the keyring:

```
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 0xBB572E0E2D182910
gpg: requesting key 0xBB572E0E2D182910 from hkp server pool.sks-keyservers.net
gpg: key 0xBB572E0E2D182910: "Gentoo Linux Release Engineering (Automated Weekly Release Key) <releng@gentoo.org>" 1 new signature
gpg: 3 marginal(s) needed, 1 complete(s) needed, classic trust model
gpg: depth: 0  valid:   3  signed:  20  trust: 0-, 0q, 0n, 0m, 0f, 3u
gpg: depth: 1  valid:  20  signed:  12  trust: 9-, 0q, 0n, 9m, 2f, 0u
gpg: next trustdb check due at 2018-09-15
gpg: Total number processed: 1
gpg:         new signatures: 1
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 0xDB6B8C1F96D8BF6D
...
```

If the appropriate keys are not available, automatic verification during
the image creation step may be disabled with the use of a flag; this
however is not recommended.

### Testing the installation

Run `bats test` to run the test suite with [bats](
https://github.com/bats-core/bats-core).


## Usage

Run `bin/createvm-gentoo --help` for a list of flags.

### Create up a minimum Gentoo VirtualBox VM

Simply execute `bin/createvm-gentoo -U` to automatically download the
required installation files, verify them, and start the base image
creation process.

The installation require the following files (the downloaded filename
will contain a timestamp, put into place by upstream).

- `install-amd64-minimal.iso`: the bootable iso for the installation
- `portage.tar.xz`: the most recent portage snapshot
- `stage3-amd64.tar.xz`: the stage3 tarball
