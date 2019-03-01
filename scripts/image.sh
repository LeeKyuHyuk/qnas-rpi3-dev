#!/bin/bash
#
# QNAS system build script
# Optional parameteres below:

set -o nounset
set -o errexit

# End of optional parameters
function step() {
  echo -e "\e[7m\e[1m>>> $1\e[0m"
}

function success() {
  echo -e "\e[1m\e[32m$1\e[0m"
}

function error() {
  echo -e "\e[1m\e[31m$1\e[0m"
}

function extract() {
  case $1 in
    *.tgz) tar -zxf $1 -C $2 ;;
    *.tar.gz) tar -zxf $1 -C $2 ;;
    *.tar.bz2) tar -jxf $1 -C $2 ;;
    *.tar.xz) tar -Jxf $1 -C $2 ;;
  esac
}

function check_environment_variable {
  if ! [[ -d $SOURCES_DIR ]] ; then
    error "Please download tarball files!"
    error "Run 'make download'."
    exit 1
  fi

  if ! [[ -d $TOOLS_DIR ]] ; then
    error "Can't find tools directory!"
    error "Run 'make toolchain'."
  fi
}

function check_tarballs {
  LIST_OF_TARBALLS="
  "

  for tarball in $LIST_OF_TARBALLS ; do
    if ! [[ -f $SOURCES_DIR/$tarball ]] ; then
      error "Can't find '$tarball'!"
      exit 1
    fi
  done
}

function timer {
  if [[ $# -eq 0 ]]; then
    echo $(date '+%s')
  else
    local stime=$1
    etime=$(date '+%s')
    if [[ -z "$stime" ]]; then stime=$etime; fi
    dt=$((etime - stime))
    ds=$((dt % 60))
    dm=$(((dt / 60) % 60))
    dh=$((dt / 3600))
    printf '%02d:%02d:%02d' $dh $dm $ds
  fi
}

check_environment_variable
check_tarballs
total_build_time=$(timer)

rm -rf $BUILD_DIR $IMAGES_DIR/{rootfs.ext2,rootfs.ext4,rpi-firmware}
mkdir -pv $BUILD_DIR

step "[7/10] Create QNAS rootfs image"
echo '#!/bin/sh' > $BUILD_DIR/_fakeroot.fs
echo "set -e" >> $BUILD_DIR/_fakeroot.fs
echo "chown -h -R 0:0 $ROOTFS_DIR" >> $BUILD_DIR/_fakeroot.fs
cat > $BUILD_DIR/_device_table.txt << EOF
# This device table is used to assign proper ownership and permissions
# on various files. It doesn't create any device file, as it is used
# in both static device configurations (where /dev/ is static) and in
# dynamic configurations (where devtmpfs, mdev or udev are used).
#
# <name>				<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
/dev					d	755	0	0	-	-	-	-	-
/dev/console	c 666 0 0 5 1 - - -
/dev/null c 666 0 0 1 3 0 0 -
/tmp					d	1777	0	0	-	-	-	-	-
/etc					d	755	0	0	-	-	-	-	-
/root					d	700	0	0	-	-	-	-	-
/var/www				d	755	33	33	-	-	-	-	-
# /etc/shadow				f	600	0	0	-	-	-	-	-
/etc/passwd				f	644	0	0	-	-	-	-	-
/etc/network/if-up.d			d	755	0	0	-	-	-	-	-
/etc/network/if-pre-up.d		d	755	0	0	-	-	-	-	-
/etc/network/if-down.d			d	755	0	0	-	-	-	-	-
/etc/network/if-post-down.d		d	755	0	0	-	-	-	-	-
EOF
if [ -d $ROOTFS_DIR/var/lib/sshd ] ; then
  echo "/var/lib/sshd	d	700	0	2	-	-	-	-	-" >> $BUILD_DIR/_device_table.txt
fi
if [ -d $ROOTFS_DIR/home/ftp ] ; then
  echo "/home/ftp	d	755	45	45	-	-	-	-	-" >> $BUILD_DIR/_device_table.txt
fi
echo "$TOOLS_DIR/bin/makedevs -d $BUILD_DIR/_device_table.txt $ROOTFS_DIR" >> $BUILD_DIR/_fakeroot.fs
echo "$TOOLS_DIR/sbin/mkfs.ext2 -d $ROOTFS_DIR $IMAGES_DIR/rootfs.ext2 $CONFIG_ROOTFS_SIZE" >> $BUILD_DIR/_fakeroot.fs
chmod a+x $BUILD_DIR/_fakeroot.fs
$TOOLS_DIR/usr/bin/fakeroot -- $BUILD_DIR/_fakeroot.fs
ln -svf rootfs.ext2 $IMAGES_DIR/rootfs.ext4
cp -rv $SUPPORT_DIR/firmware $IMAGES_DIR/rpi-firmware
$TOOLS_DIR/usr/bin/genimage \
  --rootpath "$ROOTFS_DIR" \
  --tmppath "$BUILD_DIR/genimage.tmp" \
  --inputpath "$IMAGES_DIR" \
  --outputpath "$IMAGES_DIR" \
  --config "$SUPPORT_DIR/genimage/genimage-raspberrypi3-64.cfg"
rm -rf $BUILD_DIR
success "\nTotal QNAS install image generate time: $(timer $total_build_time)\n"
