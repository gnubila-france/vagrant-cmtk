#!/bin/sh

readonly OS=$(sed -e 's/^\(.*\) release .*/\1/' /etc/redhat-release)
readonly OS_VERSION=$(sed -e 's/^.*\([0-9]\)\.\([0-9]\+\).*/\1.\2/' /etc/redhat-release)
readonly OS_VERSION_MAJ=$(echo $OS_VERSION | head -c 1)

# Update packages list
yum clean all

# Update system
#yum -y update
#echo 'System successfully updated'

echo 'Install build tools.'
yum -y install vim-enhanced gcc-c++

# On SL5/CentOS5
case $OS_VERSION_MAJ in
  5)
    echo 'Installing EPEL repo'
    rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

    echo 'Installing KBS-Extras repo'
    wget http://centos.karan.org/kbsingh-CentOS-Extras.repo \
      -O /etc/yum.repos.d/kbsingh-CentOS-Extras.repo
    rpm --import http://centos.karan.org/RPM-GPG-KEY-karan.org.txt

    if [ "$OS" -eq 'Scientific Linux' ]; then
      # On SL $releasever contains the full version
      sed -i 's/\$releasever/5/g' /etc/yum.repos.d/kbsingh-CentOS-Extras.repo
    fi

    yum --enablerepo=kbs-CentOS-Testing install -y gtkglext-devel
    ;;
  6)
    yum install -y gtkglext-devel
    ;;
  *)
    echo "Unmanaged OS version: $OS_VERSION_MAJ"
esac

# mrtrix dependencies
yum install -y glibmm24-devel gtkmm24-devel gsl-devel

# nifticlib dependencies
yum install -y csh

# camino-trackvis dependencies
yum install -y lapack-devel

# python dependencies for https, bzip2
yum install -y openssl-devel bzip2-devel

# MITK dependencies
yum install -y libtiff-devel tcp_wrappers-devel
