#!/bin/bash
#
# QNAS toolchain build script
# Optional parameteres below:
set +h
set -o nounset
set -o errexit
umask 022
export LC_ALL=POSIX

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

function do_strip {
  set +o errexit
  if [[ $CONFIG_STRIP_AND_DELETE_DOCS = 1 ]] ; then
    strip --strip-debug $TOOLS_DIR/lib/*
    strip --strip-unneeded $TOOLS_DIR/{,s}bin/*
    rm -rf $TOOLS_DIR/{,share}/{info,man,doc}
  fi
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

step "[1/1] Linux Kernel"
rm -rf $BUILD_DIR $IMAGES_DIR
mkdir -pv $BUILD_DIR $IMAGES_DIR
extract $SOURCES_DIR/6d27aa156c26977dfd079a7107e31670127d17d3.tar.gz $BUILD_DIR
make -j$PARALLEL_JOBS ARCH=$CONFIG_LINUX_ARCH mrproper -C $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3
make -j$PARALLEL_JOBS ARCH=$CONFIG_LINUX_ARCH $CONFIG_LINUX_KERNEL_DEFCONFIG -C $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3
/bin/sed -i -e "/\\<CONFIG_KERNEL_GZIP\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo 'CONFIG_KERNEL_GZIP=y' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_KERNEL_LZ4\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo '# CONFIG_KERNEL_LZ4 is not set' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_KERNEL_LZMA\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo '# CONFIG_KERNEL_LZMA is not set' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_KERNEL_LZO\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo '# CONFIG_KERNEL_LZO is not set' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_KERNEL_XZ\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo '# CONFIG_KERNEL_XZ is not set' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_CPU_LITTLE_ENDIAN\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo 'CONFIG_CPU_LITTLE_ENDIAN=y' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
# As the kernel gets compiled before root filesystems are
# built, we create a fake cpio file. It'll be
# replaced later by the real cpio archive, and the kernel will be
# rebuilt using the linux-rebuild-with-initramfs target.
/bin/sed -i -e "/\\<CONFIG_DEVTMPFS\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo 'CONFIG_DEVTMPFS=y' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
/bin/sed -i -e "/\\<CONFIG_DEVTMPFS_MOUNT\\>/d" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
echo 'CONFIG_DEVTMPFS_MOUNT=y' >> $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config
BR_BINARIES_DIR=$IMAGES_DIR KCFLAGS=-Wno-attribute-alias make -j$PARALLEL_JOBS ARCH=arm64 ARCH=$CONFIG_LINUX_ARCH INSTALL_HDR_PATH=$ROOTFS_DIR CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" DEPMOD="$TOOLS_DIR/bin/depmod.pl" INSTALL_MOD_STRIP=1 -C $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3 Image
BR_BINARIES_DIR=$IMAGES_DIR KCFLAGS=-Wno-attribute-alias make -j$PARALLEL_JOBS ARCH=arm64 ARCH=$CONFIG_LINUX_ARCH INSTALL_HDR_PATH=$ROOTFS_DIR CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" DEPMOD="$TOOLS_DIR/bin/depmod.pl" INSTALL_MOD_STRIP=1 -C $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3 broadcom/bcm2710-rpi-3-b.dtb broadcom/bcm2710-rpi-3-b-plus.dtb broadcom/bcm2837-rpi-3-b.dtb
if grep -q "CONFIG_DTC=y" $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/.config; then
  install -D -m 0755 $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/scripts/dtc/dtc $TOOLS_DIR/bin/linux-dtc ;
  ln -sf linux-dtc $TOOLS_DIR/bin/dtc;
fi
install -m 0644 -D $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/arch/arm64/boot/Image $IMAGES_DIR
# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
cp $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/arch/arm64/boot/dts/broadcom/bcm2710-rpi-3-b.dtb $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/arch/arm64/boot/dts/broadcom/bcm2710-rpi-3-b-plus.dtb $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3/arch/arm64/boot/dts/broadcom/bcm2837-rpi-3-b.dtb $IMAGES_DIR
rm -rf $BUILD_DIR/linux-6d27aa156c26977dfd079a7107e31670127d17d3

success "\nTotal kernel build time: $(timer $total_build_time)\n"
