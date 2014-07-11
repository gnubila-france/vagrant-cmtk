vagrant-cmtk
============

Building CMTK in a Vagrant box

* package-building-sh: dependencies required for building cmtk, used
  during VM creation
* build-locally.sh: script to build a cmtk tarball locally
* common.sh: helper script with some common functions.

The provided Vagrantfile allows to build cmtk in a CentOS 6 VM.

Once in the Vagrant box, do the following to build CMTK:
``` sh
cd /vagrant
rm -rf cmtk-* && ./build-locally.sh 2>&1 | tee buildlog-$(date +'%Y%m%d-%H:%M:%S')
```
