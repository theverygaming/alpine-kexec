#!/bin/sh
set -euo pipefail

cd alpine-rootfs

rm ./sbin/init
cat > ./init <<"EOF"
#!/bin/sh
mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

# reboot after 5s in case of a kernel panic
echo 5 > /proc/sys/kernel/panic

ip link set up dev lo

EXEC_CMD=$(cat /proc/cmdline | sed -n 's/.*initscript_cmd=\("[^"]*"\|\S*\).*/\1/p' | sed 's/^"\(.*\)"$/\1/')

echo "command to execute (from kernel params): '${EXEC_CMD}'" > /dev/console

/bin/sh -c "${EXEC_CMD}" 2>&1 > /dev/console

while :; do reboot -f; sleep 1; done
EOF

chmod +x ./init

# temporarily copy the resolv.conf to the chroot folder for internet access
cp /etc/resolv.conf ./etc/resolv.conf

chroot . /bin/ash -l << EOF
set -euo pipefail
apk add --no-cache \
    openssh \
    util-linux-misc \
    cryptsetup \
    lvm2 \
    e2fsprogs-extra \
    dosfstools
EOF

# delete the resolv.conf again
rm ./etc/resolv.conf

# build the initramfs image
#find . -print0 | cpio --null --create --verbose --format=newc --owner root:root > ../initramfs
#mkinitramfs -o ../initramfs -r ./ -v
find . -print0 | cpio --null --create --verbose --format=newc --owner root:root > ../initramfs

cd ..
