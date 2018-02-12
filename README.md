# vboxtools: VirtualBox tools

A set of tools for spinning up VirtualBox VMs from scratch

This is still very much a work in progress at the moment.  The goal of
this package is to provide a set of scripts that will produce a working
VirtualBox VM from various installation media, and also to assist with
automating certain tasks with the management of these VMs.


## Installation

Simply git clone this repo

### Testing

Run `bats test` to run the test suite with [bats](
https://github.com/sstephenson/bats)


## Create up a minimum Gentoo VirtualBox VM

At the current directory, provide the following files:

- `install-amd64-minimal.iso`: the bootable iso for the installation
- `portage.tar.xz`: the most recent portage snapshot
- `stage3-amd64.tar.xz`: the stage3 tarball

Place them in the current working directory, and run
`bin/createvm-gentoo`.
