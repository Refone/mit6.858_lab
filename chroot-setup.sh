#!/bin/sh -x
if id | grep -qv uid=0; then
    echo "Must run setup as root"
    exit 1
fi

create_socket_dir() {
    local dirname="$1"
    local ownergroup="$2"
    local perms="$3"

    mkdir -p $dirname
    chown $ownergroup $dirname
    chmod $perms $dirname
}

set_perms() {
    local ownergroup="$1"
    local perms="$2"
    local pn="$3"

    chown $ownergroup $pn
    chmod $perms $pn
}

rm -rf /jail
mkdir -p /jail
cp -p index.html /jail

./chroot-copy.sh zookd /jail
./chroot-copy.sh zookfs /jail

#./chroot-copy.sh /bin/bash /jail

./chroot-copy.sh /usr/bin/env /jail
./chroot-copy.sh /usr/bin/python2 /jail

# to bring in the crypto libraries
./chroot-copy.sh /usr/bin/openssl /jail

mkdir -p /jail/usr/lib /jail/usr/lib/i386-linux-gnu /jail/lib /jail/lib/i386-linux-gnu
cp -r /usr/lib/python2.7 /jail/usr/lib
cp /usr/lib/i386-linux-gnu/libsqlite3.so.0 /jail/usr/lib/i386-linux-gnu
cp /lib/i386-linux-gnu/libnss_dns.so.2 /jail/lib/i386-linux-gnu
cp /lib/i386-linux-gnu/libresolv.so.2 /jail/lib/i386-linux-gnu
cp -r /lib/resolvconf /jail/libG

mkdir -p /jail/usr/local/lib
cp -r /usr/local/lib/python2.7 /jail/usr/local/lib

mkdir -p /jail/etc
cp /etc/localtime /jail/etc/
cp /etc/timezone /jail/etc/
cp /etc/resolv.conf /jail/etc/

mkdir -p /jail/usr/share/zoneinfo
cp -r /usr/share/zoneinfo/America /jail/usr/share/zoneinfo/

#create_socket_dir /jail/echosvc 61010:61010 755
#create_socket_dir /jail/auth_svc 61010:61010 777

mkdir -p /jail/tmp
chmod a+rwxt /jail/tmp

mkdir -p /jail/dev
mknod /jail/dev/urandom c 1 9

mkdir -p /jail/auth_svc
chmod 777 /jail/auth_svc

cp -r zoobar /jail/
rm -rf /jail/zoobar/db

python /jail/zoobar/zoodb.py init-person
python /jail/zoobar/zoodb.py init-transfer
python /jail/zoobar/zoodb.py init-cred

set_perms 61015:61012 775 /jail/zoobar/db
set_perms 0:61012 770 /jail/zoobar/db/person
set_perms 0:61012 770 /jail/zoobar/db/transfer
set_perms 61015:61015 700 /jail/zoobar/db/cred

set_perms 0:61012 660 /jail/zoobar/db/person/person.db
set_perms 0:61012 660 /jail/zoobar/db/transfer/transfer.db
set_perms 61015:61015 600 /jail/zoobar/db/cred/cred.db

chown -R 0:61013 /jail/zoobar/media
chown -R 0:61013 /jail/zoobar/templates
chmod -R 660 /jail/zoobar/media/*
chmod -R 660 /jail/zoobar/templates/*

chown 0:61012 /jail/zoobar/*.py
chown 0:61012 /jail/zoobar/*.pyc
chown 61012:61012 /jail/zoobar/*.cgi
chmod 774 /jail/zoobar/*.py
chmod 774 /jail/zoobar/*.pyc
chmod 774 /jail/zoobar/*.cgi

chown 61015:61015 /jail/zoobar/auth-server.py
chmod 775 /jail/zoobar/auth-server.py
