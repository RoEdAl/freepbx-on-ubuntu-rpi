#!/bin/bash -e

UBU_IMG_FILE=ubuntu-22.04.2-preinstalled-server-arm64+raspi.img
UBX_IMG_FILE=ubuntu-22.04.2-freepbx-server-arm64.img
UBX_TAR_FILE=ubuntu-22.04.2-freepbx-server-arm64.img.tar.zstd

IMG_FS=$(stat --printf=%s $UBU_IMG_FILE)
truncate -s $IMG_FS $UBX_IMG_FILE
#truncate -s 7GiB $UBX_IMG_FILE

{
    echo 'label: dos'
    echo 'start=2048 size=524288 type=c bootable'
    echo 'size=524288 type=83'
    echo 'type=83'
} | sfdisk -q $UBX_IMG_FILE

UBU_LOOP=$(losetup -rfP --show $UBU_IMG_FILE)
UBX_LOOP=$(losetup -fP --show $UBX_IMG_FILE)

mkfs.vfat -f 1 -F 32 -R 2 -n system-boot ${UBX_LOOP}p1 &> /dev/null
mkfs.ext4 -e remount-ro -q -L uboot -O ^64bit,^has_journal,^huge_file,^inline_data,^large_dir,^large_file,ext_attr,extent,^metadata_csum ${UBX_LOOP}p2
mkfs.ext4 -e remount-ro -q -L writable -O 64bit,has_journal,^huge_file,inline_data,^large_dir,^large_file,ext_attr,extent,metadata_csum ${UBX_LOOP}p3
#mkfs.f2fs -q -O extra_attr,inode_checksum,sb_checksum,compression -l writable -t 1 ${UBX_LOOP}p3

TMP_DIR=$(mktemp -d)
mkdir -p ${TMP_DIR}/ubu
mkdir -p ${TMP_DIR}/ubx

mount -o ro ${UBU_LOOP}p2 ${TMP_DIR}/ubu
mount -o tz=UTC,ro,showexec ${UBU_LOOP}p1 ${TMP_DIR}/ubu/boot/firmware

#mount -o discard,lazytime,background_gc=off,disable_roll_forward,nobarrier ${UBX_LOOP}p3 ${TMP_DIR}/ubx
mount -o lazytime,nobarrier ${UBX_LOOP}p3 ${TMP_DIR}/ubx
mount -o lazytime,nobarrier,X-mount.mkdir ${UBX_LOOP}p2 ${TMP_DIR}/ubx/boot
mount -o tz=UTC,lazytime,showexec,X-mount.mkdir ${UBX_LOOP}p1 ${TMP_DIR}/ubx/boot/firmware

echo 'Copying files'
cp -a ${TMP_DIR}/ubu/. ${TMP_DIR}/ubx/

# modify boot files
if true; then
echo 'Modyfying fstab'
# 	-e '/^LABEL=writable/s/\<\S\+\>/ubx/2' \
#	-e '/^LABEL=writable/s/errors=[^,[:blank:]]\+/lazytime,background_gc=sync,compress_algorithm=zstd/' \
sed -i \
	-e '/^LABEL=writable/s/errors=\([^,[:blank:]]\+\)/errors=\1,commit=15/' \
	-e '/^LABEL=writable/a LABEL=uboot /boot ext4 lazytime,nombcache 0 2' \
	-e '/^LABEL=system-boot/s/\<\S\+\>/defaults,lazytime,tz=UTC,showexec,utf8=1/4' \
	-e '/^LABEL=system-boot/s/\<\S\+\>/2/6' \
	${TMP_DIR}/ubx/etc/fstab
	
#cat ${TMP_DIR}/ubx/etc/fstab

echo 'Modyfying cmdline.txt'
#    -e '/^console/s/\<rootfstype=ext4\>/rootfstype=f2fs/' \
sed -i \
    -e '/^console/s/$/ audit=0/' \
	${TMP_DIR}/ubx/boot/firmware/cmdline.txt
#cat ${TMP_DIR}/ubx/boot/firmware/cmdline.txt
fi

# systemd tuning
echo 'Tuning journal'
mkdir -p ${TMP_DIR}/ubx/etc/systemd/journald.conf.d

cat << EOF > ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/storage.conf
[Journal]
Storage=volatile
EOF

#cat ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/storage.conf

cat << EOF > ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/sysctl.conf
[Journal]
ForwardToSyslog=off
EOF

#cat ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/sysctl.conf

cat << EOF > ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/audit.conf
[Journal]
Audit=off
EOF

#cat ${TMP_DIR}/ubx/etc/systemd/journald.conf.d/audit.conf

echo 'Configuring RPi'
mv ${TMP_DIR}/ubx/boot/firmware/config.txt ${TMP_DIR}/ubx/boot/firmware/config.ubu
cat << EOF > ${TMP_DIR}/ubx/boot/firmware/config.txt
#
# Headless Raspberry Pi configuration
#
[all]
kernel=vmlinuz
cmdline=cmdline.txt
initramfs initrd.img followkernel

[all]
arm_64bit=1
enable_uart=1
dtoverlay=disable-bt
dtoverlay=disable-wifi
dtoverlay=novchiq
dtoverlay=cma,cma-size=8388608

[all]
gpu_mem=16
max_framebuffers=0
hdmi_ignore_hotplug=1
enable_tvout=0
EOF

echo 'Clearing journal'
rm -rf ${TMP_DIR}/ubx/var/log/journal/*

echo 'Configuring cloud-init logging'
cp cloud-init-logging.cfg ${TMP_DIR}/ubx/etc/cloud/cloud.cfg.d/05_logging.cfg

echo 'Configuring cloud-init datasource'
cp freepbx-user-data.gz ${TMP_DIR}/ubx/boot/firmware/user-data
cp network-config.yml ${TMP_DIR}/ubx/boot/firmware/network-config

echo 'Unmounting'
umount -R ${TMP_DIR}/ubu

fstrim -v ${TMP_DIR}/ubx/boot/firmware
fstrim -v ${TMP_DIR}/ubx/boot
fstrim -v ${TMP_DIR}/ubx
umount -R ${TMP_DIR}/ubx

echo 'Detaching loop devices'
losetup -d $UBU_LOOP $UBX_LOOP

echo 'Removing temporary directory'
rm -rf $TMP_DIR

chown $SUDO_UID:$SUDO_GID $UBX_IMG_FILE
du -h $UBX_IMG_FILE
du -h --apparent-size $UBX_IMG_FILE

# tar -Sc --zstd -f $UBX_TAR_FILE $UBX_IMG_FILE
# du -h $UBX_TAR_FILE

#xz -1 $UBX_IMG_FILE

