#!/bin/sh
set -euo pipefail

curl https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz -o alpine-rootfs.tar.gz
mkdir alpine-rootfs
tar xf alpine-rootfs.tar.gz -C alpine-rootfs
cd alpine-rootfs
rm ./sbin/init
cat > ./sbin/init <<EOF
#!/bin/sh
mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys
ip link set up dev lo

exec /sbin/getty -n -l /bin/sh 115200 /dev/console
poweroff -f
EOF

chmod +x ./sbin/init

# temporarily copy the resolv.conf to the chroot folder for internet access
cp /etc/resolv.conf ./etc/resolv.conf

chroot . /bin/ash -l << EOF
set -euo pipefail
apk add --no-cache openssh openrc
rc-update add sshd
EOF

# delete the resolv.conf again
rm ./etc/resolv.conf

# build the initramfs image
#find . -print0 | cpio --null --create --verbose --format=newc --owner root:root > ../initramfs
#mkinitramfs -o ../initramfs -r ./ -v
find . | sort | cpio --quiet --renumber-inodes -o -H newc > ../initramfs

cd ..


# lmao there is probably a FAR better way of grabbing the linux kernel binary from alpine pkgs
#apk add --no-cache linux-lts
#ls -lah /boot/vmlinuz-lts
#mv /boot/vmlinuz-lts ./kernel
