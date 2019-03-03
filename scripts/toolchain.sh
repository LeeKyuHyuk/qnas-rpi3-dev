#!/bin/bash
#
# QNAS toolchain build script
# Optional parameteres below:
set +h
set -o nounset
set -o errexit
umask 022

export CFLAGS="-O2 -I$TOOLS_DIR/include"
export CPPFLAGS="-O2 -I$TOOLS_DIR/include"
export CXXFLAGS="-O2 -I$TOOLS_DIR/include"
export LDFLAGS="-L$TOOLS_DIR/lib -Wl,-rpath,$TOOLS_DIR/lib"

export LC_ALL=POSIX
export CONFIG_HOST=`echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/'`

CONFIG_PKG_VERSION="QNAS Raspberry Pi 3 64bit 2019.03"
CONFIG_BUG_URL="https://github.com/LeeKyuHyuk/qnas/issues"

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
  bc-1.06.95.tar.bz2
  binutils-2.32.tar.xz
  confuse-3.2.2.tar.xz
  dosfstools-4.1.tar.xz
  e2fsprogs-1.44.5.tar.xz
  fakeroot_1.23.orig.tar.xz
  gcc-8.3.0.tar.xz
  genimage-10.tar.xz
  gmp-6.1.2.tar.xz
  libcap-2.26.tar.xz
  mpc-1.1.0.tar.gz
  mpfr-4.0.1.tar.xz
  mtools-4.0.21.tar.bz2
  musl-1.1.21.tar.gz
  pkg-config-0.29.2.tar.gz
  util-linux-2.33.tar.xz
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

step "[1/37] Create toolchain directory."
rm -rf $BUILD_DIR $TOOLS_DIR
mkdir -pv $BUILD_DIR $TOOLS_DIR
ln -svf . $TOOLS_DIR/usr

step "[2/37] Create the sysroot directory"
mkdir -pv $SYSROOT_DIR
ln -svf . $SYSROOT_DIR/usr
if [[ "$CONFIG_LINUX_ARCH" = "arm" ]] ; then
  ln -snvf lib $SYSROOT_DIR/lib32
fi
if [[ "$CONFIG_LINUX_ARCH" = "arm64" ]] ; then
  ln -snvf lib $SYSROOT_DIR/lib64
fi

step "[3/37] Linux API Headers"
make -j$PARALLEL_JOBS ARCH=$CONFIG_LINUX_ARCH mrproper -C $WORKSPACE_DIR/kernel
make -j$PARALLEL_JOBS ARCH=$CONFIG_LINUX_ARCH headers_check -C $WORKSPACE_DIR/kernel
make -j$PARALLEL_JOBS ARCH=$CONFIG_LINUX_ARCH INSTALL_HDR_PATH=$SYSROOT_DIR headers_install -C $WORKSPACE_DIR/kernel

step "[32/37] binutils 2.29.1"
extract $SOURCES_DIR/binutils-2.32.tar.xz $BUILD_DIR
mkdir -pv $BUILD_DIR/binutils-2.32/binutils-build
( cd $BUILD_DIR/binutils-2.32/binutils-build && \
$BUILD_DIR/binutils-2.32/configure \
--prefix=$TOOLS_DIR \
--target=$CONFIG_TARGET \
--with-sysroot=$SYSROOT_DIR \
--disable-nls \
--disable-multilib )
make -j$PARALLEL_JOBS configure-host -C $BUILD_DIR/binutils-2.32/binutils-build
make -j$PARALLEL_JOBS -C $BUILD_DIR/binutils-2.32/binutils-build
make -j$PARALLEL_JOBS install -C $BUILD_DIR/binutils-2.32/binutils-build
rm -rf $BUILD_DIR/binutils-2.32

step "[33/37] gcc 8.3.0 - Static"
extract $SOURCES_DIR/gcc-8.3.0.tar.xz $BUILD_DIR
extract $SOURCES_DIR/gmp-6.1.2.tar.xz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/gmp-6.1.2 $BUILD_DIR/gcc-8.3.0/gmp
extract $SOURCES_DIR/mpfr-4.0.1.tar.xz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/mpfr-4.0.1 $BUILD_DIR/gcc-8.3.0/mpfr
extract $SOURCES_DIR/mpc-1.1.0.tar.gz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/mpc-1.1.0 $BUILD_DIR/gcc-8.3.0/mpc
mkdir -pv $BUILD_DIR/gcc-8.3.0/gcc-build
( cd $BUILD_DIR/gcc-8.3.0/gcc-build && \
  $BUILD_DIR/gcc-8.3.0/configure \
  --prefix=$TOOLS_DIR \
  --build=$CONFIG_HOST \
  --host=$CONFIG_HOST \
  --target=$CONFIG_TARGET \
  --with-sysroot=$SYSROOT_DIR \
  --disable-nls \
  --disable-shared \
  --without-headers \
  --with-newlib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libatomic \
  --disable-libquadmath \
  --disable-threads \
  --enable-languages=c \
  --disable-multilib \
  --with-abi="lp64" \
  --with-cpu=cortex-a53 \
  --with-pkgversion="$CONFIG_PKG_VERSION" \
  --with-bugurl="$CONFIG_BUG_URL" )
make -j$PARALLEL_JOBS all-gcc all-target-libgcc -C $BUILD_DIR/gcc-8.3.0/gcc-build
make -j$PARALLEL_JOBS install-gcc install-target-libgcc -C $BUILD_DIR/gcc-8.3.0/gcc-build
rm -rf $BUILD_DIR/gcc-8.3.0

step "[35/37] musl 1.1.21"
extract $SOURCES_DIR/musl-1.1.21.tar.gz $BUILD_DIR
( cd $BUILD_DIR/musl-1.1.21 && \
  ./configure \
  CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" \
  --prefix=/ \
  --target=$CONFIG_TARGET )
make -j$PARALLEL_JOBS -C $BUILD_DIR/musl-1.1.21
DESTDIR=$SYSROOT_DIR make -j$PARALLEL_JOBS install -C $BUILD_DIR/musl-1.1.21
rm -rf $BUILD_DIR/musl-1.1.21

step "[36/37] gcc 8.3.0 - Final"
extract $SOURCES_DIR/gcc-8.3.0.tar.xz $BUILD_DIR
extract $SOURCES_DIR/gmp-6.1.2.tar.xz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/gmp-6.1.2 $BUILD_DIR/gcc-8.3.0/gmp
extract $SOURCES_DIR/mpfr-4.0.1.tar.xz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/mpfr-4.0.1 $BUILD_DIR/gcc-8.3.0/mpfr
extract $SOURCES_DIR/mpc-1.1.0.tar.gz $BUILD_DIR/gcc-8.3.0
mv -v $BUILD_DIR/gcc-8.3.0/mpc-1.1.0 $BUILD_DIR/gcc-8.3.0/mpc
mkdir -v $BUILD_DIR/gcc-8.3.0/gcc-build
( cd $BUILD_DIR/gcc-8.3.0/gcc-build && \
  $BUILD_DIR/gcc-8.3.0/configure \
  --prefix=$TOOLS_DIR \
  --build=$CONFIG_HOST \
  --host=$CONFIG_HOST \
  --target=$CONFIG_TARGET \
  --with-sysroot=$SYSROOT_DIR \
  --disable-nls \
  --enable-languages=c \
  --enable-c99 \
  --enable-long-long \
  --disable-libmudflap \
  --disable-multilib \
  --with-abi="lp64" \
  --with-cpu=cortex-a53 \
  --with-pkgversion="$CONFIG_PKG_VERSION" \
  --with-bugurl="$CONFIG_BUG_URL" )
make -j$PARALLEL_JOBS -C $BUILD_DIR/gcc-8.3.0/gcc-build
make -j$PARALLEL_JOBS install -C $BUILD_DIR/gcc-8.3.0/gcc-build
if [ ! -e $TOOLS_DIR/bin/$CONFIG_TARGET-cc ]; then
  ln -vf $TOOLS_DIR/bin/$CONFIG_TARGET-gcc $TOOLS_DIR/bin/$CONFIG_TARGET-cc
fi
rm -rf $BUILD_DIR/gcc-8.3.0

step "[20/37] pkg-config-0.29.2"
extract $SOURCES_DIR/pkg-config-0.29.2.tar.gz $BUILD_DIR
( cd $BUILD_DIR/pkg-config-0.29.2 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static \
--with-internal-glib \
--enable-host-tool )
make -j$PARALLEL_JOBS -C $BUILD_DIR/pkg-config-0.29.2
make -j$PARALLEL_JOBS install -C $BUILD_DIR/pkg-config-0.29.2
rm -rf $BUILD_DIR/pkg-config-0.29.2

step "[10/37] bc 1.06.95"
extract $SOURCES_DIR/bc-1.06.95.tar.bz2 $BUILD_DIR
sed -i "s/makeinfo --no-split/@MAKEINFO@ --no-split/g" $BUILD_DIR/bc-1.06.95/doc/Makefile.in
( cd $BUILD_DIR/bc-1.06.95 && \
MAKEINFO=true \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static )
make -j$PARALLEL_JOBS -C $BUILD_DIR/bc-1.06.95
make -j$PARALLEL_JOBS install -C $BUILD_DIR/bc-1.06.95
rm -rf $BUILD_DIR/bc-1.06.95

step "[19/37] util-linux 2.33"
extract $SOURCES_DIR/util-linux-2.33.tar.xz $BUILD_DIR
( cd $BUILD_DIR/util-linux-2.33 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static \
--without-python \
--enable-libblkid \
--enable-libmount \
--enable-libuuid \
--without-ncurses \
--without-ncursesw \
--without-tinfo \
--disable-makeinstall-chown \
--disable-more )
make -j$PARALLEL_JOBS -C $BUILD_DIR/util-linux-2.33
make -j$PARALLEL_JOBS install -C $BUILD_DIR/util-linux-2.33
rm -rf $BUILD_DIR/util-linux-2.33

step "[20/37] dosfstools 4.1"
extract $SOURCES_DIR/dosfstools-4.1.tar.xz $BUILD_DIR
( cd $BUILD_DIR/dosfstools-4.1 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static \
--enable-compat-symlinks )
make -j$PARALLEL_JOBS -C $BUILD_DIR/dosfstools-4.1
make -j$PARALLEL_JOBS install -C $BUILD_DIR/dosfstools-4.1
rm -rf $BUILD_DIR/dosfstools-4.1

step "[21/37] e2fsprogs 1.44.5"
extract $SOURCES_DIR/e2fsprogs-1.44.5.tar.xz $BUILD_DIR
( cd $BUILD_DIR/e2fsprogs-1.44.5 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static \
--disable-defrag \
--disable-e2initrd-helper \
--disable-fuse2fs \
--disable-libblkid \
--disable-libuuid \
--enable-symlink-install \
--disable-testio-debug )
make -j$PARALLEL_JOBS -C $BUILD_DIR/e2fsprogs-1.44.5
make -j$PARALLEL_JOBS install install-libs -C $BUILD_DIR/e2fsprogs-1.44.5
rm -rf $BUILD_DIR/e2fsprogs-1.44.5

step "[23/37] libconfuse 3.2.2"
extract $SOURCES_DIR/confuse-3.2.2.tar.xz $BUILD_DIR
( cd $BUILD_DIR/confuse-3.2.2 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static )
make -j$PARALLEL_JOBS -C $BUILD_DIR/confuse-3.2.2
make -j$PARALLEL_JOBS install -C $BUILD_DIR/confuse-3.2.2
rm -rf $BUILD_DIR/confuse-3.2.2

step "[24/37] genimage 10"
extract $SOURCES_DIR/genimage-10.tar.xz $BUILD_DIR
( cd $BUILD_DIR/genimage-10 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static )
make -j$PARALLEL_JOBS -C $BUILD_DIR/genimage-10
make -j$PARALLEL_JOBS install -C $BUILD_DIR/genimage-10
rm -rf $BUILD_DIR/genimage-10

step "[25/37] mtools 4.0.21"
extract $SOURCES_DIR/mtools-4.0.21.tar.bz2 $BUILD_DIR
( cd $BUILD_DIR/mtools-4.0.21 && \
./configure \
--prefix=$TOOLS_DIR \
--enable-shared \
--disable-static )
make -j$PARALLEL_JOBS -C $BUILD_DIR/mtools-4.0.21
make -j$PARALLEL_JOBS install -C $BUILD_DIR/mtools-4.0.21
rm -rf $BUILD_DIR/mtools-4.0.21

step "[27/37] libcap 2.26"
extract $SOURCES_DIR/libcap-2.26.tar.xz $BUILD_DIR
make -j$PARALLEL_JOBS RAISE_SETFCAP=no -C $BUILD_DIR/libcap-2.26
make -j$PARALLEL_JOBS DESTDIR=$TOOLS_DIR RAISE_SETFCAP=no prefix=/usr lib=lib install -C $BUILD_DIR/libcap-2.26
rm -rf $BUILD_DIR/libcap-2.26

step "[28/37] fakeroot 1.22"
extract $SOURCES_DIR/fakeroot_1.23.orig.tar.xz $BUILD_DIR
( cd $BUILD_DIR/fakeroot-1.23 && \
./configure \
--prefix="$TOOLS_DIR" \
--sysconfdir="$TOOLS_DIR/etc" \
--localstatedir="$TOOLS_DIR/var" \
--enable-shared \
--disable-static )
make -j$PARALLEL_JOBS -C $BUILD_DIR/fakeroot-1.23
make -j$PARALLEL_JOBS install -C $BUILD_DIR/fakeroot-1.23
rm -rf $BUILD_DIR/fakeroot-1.23

step "[29/37] mkpasswd 5.0.26"
gcc -O2 -I$TOOLS_DIR/include -L$TOOLS_DIR/lib -L$TOOLS_DIR/lib -Wl,-rpath,$TOOLS_DIR/lib $SUPPORT_DIR/mkpasswd/mkpasswd.c $SUPPORT_DIR/mkpasswd/utils.c -o $TOOLS_DIR/bin/mkpasswd -lcrypt
chmod 755 $TOOLS_DIR/bin/mkpasswd

step "[30/37] makedevs"
gcc -O2 -I$TOOLS_DIR/include $SUPPORT_DIR/makedevs/makedevs.c -o $TOOLS_DIR/bin/makedevs -L$TOOLS_DIR/lib -L$TOOLS_DIR/lib -Wl,-rpath,$TOOLS_DIR/lib
chmod 755 $TOOLS_DIR/bin/makedevs

do_strip

success "\nTotal toolchain build time: $(timer $total_build_time)\n"
