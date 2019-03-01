export CONFIG_TARGET = aarch64-qnas-linux-musl
export CONFIG_LINUX_ARCH = arm64
export CONFIG_LINUX_KERNEL_DEFCONFIG = bcmrpi3_defconfig
export CONFIG_ROOTFS_SIZE = 50M
# Strip binaries and delete manpages
export CONFIG_STRIP_AND_DELETE_DOCS = 1
# Root user password
export CONFIG_ROOT_PASSWD = qnas
# Hostname
export CONFIG_HOSTNAME = qnas
# Local timezone
export CONFIG_LOCAL_TIMEZONE = Asia/Seoul
