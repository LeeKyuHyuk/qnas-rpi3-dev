#!/bin/bash
#
# QNAS system build script
# Optional parameteres below:
set +h
set -o nounset
set -o errexit
umask 022

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

  if ! [[ -d $TOOLS_DIR ]] ; then
    error "Can't find tools directory!"
    error "Run 'make toolchain'."
  fi
}

function check_tarballs {
  LIST_OF_TARBALLS="
  busybox-1.30.1.tar.bz2
  e2fsprogs-1.44.5.tar.xz
  musl-1.1.21.tar.gz
  openssh-7.9p1.tar.gz
  openssl-1.0.2p.tar.gz
  util-linux-2.33.tar.xz
  vsftpd-3.0.3.tar.gz
  zlib-1.2.11.tar.gz
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
    $CONFIG_TARGET-strip --strip-debug $ROOTFS_DIR/lib/*
    $CONFIG_TARGET-strip --strip-unneeded $ROOTFS_DIR/{,s}bin/*
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

export CC="$TOOLS_DIR/bin/$CONFIG_TARGET-gcc --sysroot=$ROOTFS_DIR"
export CXX="$TOOLS_DIR/bin/$CONFIG_TARGET-g++ --sysroot=$ROOTFS_DIR"
export AR="$TOOLS_DIR/bin/$CONFIG_TARGET-ar"
export AS="$TOOLS_DIR/bin/$CONFIG_TARGET-as"
export LD="$TOOLS_DIR/bin/$CONFIG_TARGET-ld --sysroot=$ROOTFS_DIR"
export RANLIB="$TOOLS_DIR/bin/$CONFIG_TARGET-ranlib"
export READELF="$TOOLS_DIR/bin/$CONFIG_TARGET-readelf"
export STRIP="$TOOLS_DIR/bin/$CONFIG_TARGET-strip"

export CONFIG_HOST=`echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/'`

rm -rf $BUILD_DIR $ROOTFS_DIR
mkdir -pv $BUILD_DIR $ROOTFS_DIR

step "[1/11] Creating Directories"
mkdir -pv $ROOTFS_DIR/{dev,etc,lib,media,mnt,opt,proc,root,run,sys,tmp,usr,qnas}
ln -snvf ../proc/self/fd $ROOTFS_DIR/dev/fd
ln -snvf ../proc/self/fd/2 $ROOTFS_DIR/dev/stderr
ln -snvf ../proc/self/fd/0 $ROOTFS_DIR/dev/stdin
ln -snvf ../proc/self/fd/1 $ROOTFS_DIR/dev/stdout
ln -snvf ../proc/self/mounts $ROOTFS_DIR/etc/mtab
ln -snvf ../tmp/resolv.conf $ROOTFS_DIR/etc/resolv.conf
cp -v $SUPPORT_DIR/skeleton/etc/{group,hosts,passwd,profile,protocols,services,shadow} $ROOTFS_DIR/etc
sed -i -e s,^root:[^:]*:,root:"`$TOOLS_DIR/bin/mkpasswd -m "sha-512" "$CONFIG_ROOT_PASSWD"`":, $ROOTFS_DIR/etc/shadow
mkdir -pv $ROOTFS_DIR/profile.d
cp -v $SUPPORT_DIR/skeleton/etc/profile.d/umask.sh $ROOTFS_DIR/etc/profile.d
mkdir -pv $ROOTFS_DIR/usr/{bin,lib,sbin}
if [[ "$CONFIG_LINUX_ARCH" = "arm" ]] ; then
  ln -snvf lib $ROOTFS_DIR/lib32
  ln -snvf lib $ROOTFS_DIR/usr/lib32
fi
if [[ "$CONFIG_LINUX_ARCH" = "arm64" ]] ; then
  ln -snvf lib $ROOTFS_DIR/lib64
  ln -snvf lib $ROOTFS_DIR/usr/lib64
fi
mkdir -pv $ROOTFS_DIR/var/log

step "[2/11] Creating the /etc/fstab File"
cat > $ROOTFS_DIR/etc/fstab << "EOF"
# <file system>	<mount pt>	<type>	<options>	<dump>	<pass>
/dev/root	/		ext2	rw,noauto	0	1
proc		/proc		proc	defaults	0	0
devpts		/dev/pts	devpts	defaults,gid=5,mode=620,ptmxmode=0666	0	0
tmpfs		/dev/shm	tmpfs	mode=0777	0	0
tmpfs		/tmp		tmpfs	mode=1777	0	0
tmpfs		/run		tmpfs	mode=0755,nosuid,nodev	0	0
sysfs		/sys		sysfs	defaults	0	0
/dev/sda	/qnas	auto	defaults,rw	0	0
EOF

step "[3/11] libgcc 6.2.0"
cp -v $SYSROOT_DIR/lib/libgcc_s.so.1 $ROOTFS_DIR/lib/
$TOOLS_DIR/bin/$CONFIG_TARGET-strip $ROOTFS_DIR/lib/libgcc_s.so.1

step "[4/11] Musl 1.1.21"
extract $SOURCES_DIR/musl-1.1.21.tar.gz $BUILD_DIR
( cd $BUILD_DIR/musl-1.1.21 && \
  ./configure \
  CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" \
  --prefix=/ \
  --disable-static \
  --target=$CONFIG_TARGET )
make -j$PARALLEL_JOBS -C $BUILD_DIR/musl-1.1.21
DESTDIR=$ROOTFS_DIR make -j$PARALLEL_JOBS install-libs -C $BUILD_DIR/musl-1.1.21
rm -rf $BUILD_DIR/musl-1.1.21

step "[5/11] Busybox 1.30.1"
extract $SOURCES_DIR/busybox-1.30.1.tar.bz2 $BUILD_DIR
make -j$PARALLEL_JOBS distclean -C $BUILD_DIR/busybox-1.30.1
make -j$PARALLEL_JOBS ARCH="$CONFIG_LINUX_ARCH" defconfig -C $BUILD_DIR/busybox-1.30.1
# Disable building both ifplugd and inetd as they both have issues building against musl:
sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' $BUILD_DIR/busybox-1.30.1/.config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' $BUILD_DIR/busybox-1.30.1/.config
# Disable the use of utmp/wtmp as musl does not support them:
sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' $BUILD_DIR/busybox-1.30.1/.config
sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' $BUILD_DIR/busybox-1.30.1/.config
# Disable the use of ipsvd for both TCP and UDP as it has issues building against musl (similar to inetd's issues):
sed -i 's/\(CONFIG_UDPSVD\)=y/# \1 is not set/' $BUILD_DIR/busybox-1.30.1/.config
sed -i 's/\(CONFIG_TCPSVD\)=y/# \1 is not set/' $BUILD_DIR/busybox-1.30.1/.config
make -j$PARALLEL_JOBS ARCH="$CONFIG_LINUX_ARCH" CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" -C $BUILD_DIR/busybox-1.30.1
make -j$PARALLEL_JOBS ARCH="$CONFIG_LINUX_ARCH" CROSS_COMPILE="$TOOLS_DIR/bin/$CONFIG_TARGET-" CONFIG_PREFIX="$ROOTFS_DIR" install -C $BUILD_DIR/busybox-1.30.1
if grep -q "CONFIG_UDHCPC=y" $BUILD_DIR/busybox-1.30.1/.config; then
  install -m 0755 -Dv $SUPPORT_DIR/skeleton/usr/share/udhcpc/default.script $ROOTFS_DIR/usr/share/udhcpc/default.script
  install -m 0755 -dv $ROOTFS_DIR/usr/share/udhcpc/default.script.d
fi
if grep -q "CONFIG_SYSLOGD=y" $BUILD_DIR/busybox-1.30.1/.config; then
  install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/S01logging $ROOTFS_DIR/etc/init.d/S01logging
else
  rm -fv $ROOTFS_DIR/etc/init.d/S01logging
fi
if grep -q "CONFIG_FEATURE_TELNETD_STANDALONE=y" $BUILD_DIR/busybox-1.30.1/.config; then
  install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/S50telnet $ROOTFS_DIR/etc/init.d/S50telnet
fi
install -Dv -m 0644 $SUPPORT_DIR/skeleton/etc/inittab $ROOTFS_DIR/etc/inittab
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/rcK $ROOTFS_DIR/etc/init.d/rcK
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/rcS $ROOTFS_DIR/etc/init.d/rcS
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/S20urandom $ROOTFS_DIR/etc/init.d/S20urandom
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/init.d/S40network $ROOTFS_DIR/etc/init.d/S40network
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/network/if-pre-up.d/wait_iface $ROOTFS_DIR/etc/network/if-pre-up.d/wait_iface
install -m 0755 -Dv $SUPPORT_DIR/skeleton/etc/network/nfs_check $ROOTFS_DIR/etc/network/nfs_check
cp -v $SUPPORT_DIR/skeleton/etc/network/interfaces $ROOTFS_DIR/etc/network/interfaces
sed -i -e '/# GENERIC_SERIAL$/s~^.*#~ttyAMA0::respawn:/sbin/getty -L  ttyAMA0 0 vt100 #~' $ROOTFS_DIR/etc/inittab
sed -i -e '/^#.*-o remount,rw \/$/s~^#\+~~' $ROOTFS_DIR/etc/inittab
echo "$CONFIG_HOSTNAME" > $ROOTFS_DIR/etc/hostname
echo "127.0.1.1	$CONFIG_HOSTNAME" >> $ROOTFS_DIR/etc/hosts
echo "Welcome to QNAS" > $ROOTFS_DIR/etc/issue
# If you're going to build your kernel with modules, you will need to make sure depmod.pl is available for your host to execute:
cp -v $BUILD_DIR/busybox-1.30.1/examples/depmod.pl $TOOLS_DIR/bin
chmod -v 755 $TOOLS_DIR/bin/depmod.pl
rm -rf $BUILD_DIR/busybox-1.30.1

step "[6/11] util-linux 2.33"
extract $SOURCES_DIR/util-linux-2.33.tar.xz $BUILD_DIR
( cd $BUILD_DIR/util-linux-2.33 && \
./configure \
--target=$CONFIG_TARGET \
--host=$CONFIG_TARGET \
--build=$CONFIG_HOST \
--prefix=/usr \
--disable-chfn-chsh  \
--disable-login \
--disable-nologin \
--disable-su \
--disable-setpriv \
--disable-runuser \
--disable-pylibmount \
--disable-static \
--without-python \
--without-systemd \
--without-systemdsystemunitdir \
--disable-makeinstall-chown )
make -j$PARALLEL_JOBS -C $BUILD_DIR/util-linux-2.33
make -j$PARALLEL_JOBS DESTDIR=$ROOTFS_DIR install -C $BUILD_DIR/util-linux-2.33
rm -rf $BUILD_DIR/util-linux-2.33

step "[7/11] e2fsprogs 1.44.5"
extract $SOURCES_DIR/e2fsprogs-1.44.5.tar.xz $BUILD_DIR
( cd $BUILD_DIR/e2fsprogs-1.44.5 && \
./configure \
--target=$CONFIG_TARGET \
--host=$CONFIG_TARGET \
--build=$CONFIG_HOST \
--prefix=/usr \
--bindir=/bin \
--disable-uuidd \
--disable-libblkid \
--disable-libuuid \
--disable-e2initrd-helper \
--disable-testio-debug \
--disable-rpath \
--enable-symlink-install )
make -j$PARALLEL_JOBS -C $BUILD_DIR/e2fsprogs-1.44.5
make -j1 DESTDIR=$ROOTFS_DIR install install-libs -C $BUILD_DIR/e2fsprogs-1.44.5
rm -rf $BUILD_DIR/e2fsprogs-1.44.5

step "[8/11] Zlib 1.2.11"
extract $SOURCES_DIR/zlib-1.2.11.tar.gz $BUILD_DIR
( cd $BUILD_DIR/zlib-1.2.11 && CC=$TOOLS_DIR/bin/$CONFIG_TARGET-gcc ./configure --prefix="/usr" )
make -j1 -C $BUILD_DIR/zlib-1.2.11
make -j1 DESTDIR=$ROOTFS_DIR LDCONFIG=true install -C $BUILD_DIR/zlib-1.2.11
rm -rf $BUILD_DIR/zlib-1.2.11

step "[9/11] Openssl 1.0.2p"
extract $SOURCES_DIR/openssl-1.0.2p.tar.gz $BUILD_DIR
( cd $BUILD_DIR/openssl-1.0.2p && \
./Configure \
linux-aarch64 \
--prefix=/usr \
--openssldir=/etc/ssl \
--libdir=/lib \
shared \
zlib-dynamic )
make -j1 -C $BUILD_DIR/openssl-1.0.2p
make -j1 INSTALL_PREFIX=$ROOTFS_DIR install -C $BUILD_DIR/openssl-1.0.2p
rm -rf $BUILD_DIR/openssl-1.0.2p

step "[10/11] Openssh 7.9p1"
extract $SOURCES_DIR/openssh-7.9p1.tar.gz $BUILD_DIR
( cd $BUILD_DIR/openssh-7.9p1 && \
LD="$TOOLS_DIR/bin/$CONFIG_TARGET-gcc" \
LDFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os " \
./configure \
--target=$CONFIG_TARGET \
--host=$CONFIG_TARGET \
--build=$CONFIG_HOST \
--prefix=/usr \
--exec-prefix=/usr \
--sysconfdir=/etc \
--localstatedir=/var \
--program-prefix="" \
--disable-nls \
--disable-static \
--enable-shared \
--sysconfdir=/etc/ssh \
--with-privsep-path=/var/lib/sshd \
--disable-lastlog \
--disable-utmp \
--disable-utmpx \
--disable-wtmp \
--disable-wtmpx \
--disable-strip \
--without-ssl-engine \
--without-pam \
--without-selinux )
make -j$PARALLEL_JOBS -C $BUILD_DIR/openssh-7.9p1
make -j$PARALLEL_JOBS DESTDIR=$ROOTFS_DIR install -C $BUILD_DIR/openssh-7.9p1
echo 'sshd:x:50:' >> $ROOTFS_DIR/etc/group
echo 'sshd:x:50:50:sshd PrivSep:/var/lib/sshd:/bin/false' >> $ROOTFS_DIR/etc/passwd
echo "PermitRootLogin yes" >> $ROOTFS_DIR/etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> $ROOTFS_DIR/etc/ssh/sshd_config
install -Dv -m 755 $SUPPORT_DIR/openssh/sshd $ROOTFS_DIR/etc/init.d/S50sshd
rm -rf $BUILD_DIR/openssh-7.9p1

step "[11/11] Vsftpd 3.0.3"
extract $SOURCES_DIR/vsftpd-3.0.3.tar.gz $BUILD_DIR
sed -i -e 's@#-pedantic -Wconversion@-Wno-discarded-qualifiers -Wno-stringop-truncation@g' $BUILD_DIR/vsftpd-3.0.3/Makefile
patch -Np1 -i $SUPPORT_DIR/vsftpd/sysdeputil.c-Fix-with-musl-which-does-not-have-utmpx.patch -d $BUILD_DIR/vsftpd-3.0.3
patch -Np1 -i $SUPPORT_DIR/vsftpd/utmpx-builddef.patch -d $BUILD_DIR/vsftpd-3.0.3
patch -Np1 -i $SUPPORT_DIR/vsftpd/fix-CVE-2015-1419.patch -d $BUILD_DIR/vsftpd-3.0.3
sed -i -e "s@gcc@$CONFIG_TARGET-gcc --sysroot=$ROOTFS_DIR@" $BUILD_DIR/vsftpd-3.0.3/Makefile
make -j$PARALLEL_JOBS -C $BUILD_DIR/vsftpd-3.0.3
install -v -d -m 0755 $ROOTFS_DIR/usr/share/vsftpd/empty
install -v -d -m 0755 $ROOTFS_DIR/home/ftp
echo "ftp:x:45:" >> $ROOTFS_DIR/etc/group
echo "vsftpd:x:47:" >> $ROOTFS_DIR/etc/group
echo "ftp:x:45:45:ftp:/home/ftp:/bin/false" >> $ROOTFS_DIR/etc/passwd
echo "vsftpd:x:47:47:vsftpd:/dev/null:/bin/false" >> $ROOTFS_DIR/etc/passwd
install -v -m 755 $BUILD_DIR/vsftpd-3.0.3/vsftpd $ROOTFS_DIR/usr/sbin/vsftpd
install -v -m 755 $SUPPORT_DIR/vsftpd/vsftpd $ROOTFS_DIR/etc/init.d/S70vsftpd
install -v -m 644 $SUPPORT_DIR/vsftpd/vsftpd.conf $ROOTFS_DIR/etc
mkdir -pv $ROOTFS_DIR/usr/share/empty
rm -rf $BUILD_DIR/vsftpd-3.0.3

success "\nTotal system build time: $(timer $total_build_time)\n"
