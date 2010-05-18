#!/bin/bash
# updates apt, installs REE, curl and rsync
# sets gem source to gemcutter

# <UDF name="ree_version" Label="Ruby Enterprise Edition Version" default="1.8.7-2010.01" example="1.8.7-2010.01" />

# Set up these env vars for testing locally; Should be set from UDF if run through Linode

if [ ! -n "$REE_VERSION" ]; then
  REE_VERSION="1.8.7-2010.01"
fi

echo "bootstrapping ruby"
apt-get  -y update
aptitude -y full-upgrade
apt-get  -y install curl rsync

# REE from deb
case `uname -m` in
  i386|i686)
    ree="http://rubyforge.org/frs/download.php/68718/ruby-enterprise_${REE_VERSION}_i386.deb";;
  x86_64)
    ree="http://rubyforge.org/frs/download.php/68718/ruby-enterprise_${REE_VERSION}_amd64.deb";;
esac

curl -L -o ree.deb $ree
dpkg -i ree.deb

gem sources -a 'http://gemcutter.org'

mkdir -p /usr/local/ruby-enterprise; ln -nsf /usr/local/bin /usr/local/ruby-enterprise/bin
