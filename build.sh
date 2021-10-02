#!/usr/bin/env bash

cd $(dirname $0)

ver=""
if [ -n "$2" ]; then
    ver="-b $2"
fi

if [ ! -d "coredns" ]; then
    git clone https://github.com/coredns/coredns --depth 1 $ver
    cd coredns
else
    cd coredns
    git checkout .
    git pull
fi

echo "dnsredir:github.com/leiless/dnsredir" >> plugin.cfg
git apply ../log-add-timestamp.patch

make
if [ $? -ne 0 ]; then
    echo "build coredns failed"
    exit 1
fi

if [ "$1" == "release" ]; then
    zip -9 ../coredns_linux_amd64.zip ./coredns
else
    sudo supervisord ctl stop coredns
    sudo cp coredns /usr/local/bin/
    sudo supervisord ctl start coredns
fi

