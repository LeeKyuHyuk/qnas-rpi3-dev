include settings.mk

.PHONY: all toolchain system kernel image clean

help:
	$(SCRIPTS_DIR)/help.sh

all:
	make clean toolchain system kernel image

toolchain:
	make toolchain sysroot -C $(PACKAGES_DIR)/skeleton
	make toolchain -C $(PACKAGES_DIR)/pkgconf
	make toolchain -C $(PACKAGES_DIR)/zlib
	make toolchain -C $(PACKAGES_DIR)/util-linux
	make toolchain -C $(PACKAGES_DIR)/e2fsprogs
	make toolchain -C $(PACKAGES_DIR)/libcap
	make toolchain -C $(PACKAGES_DIR)/fakeroot
	make toolchain -C $(PACKAGES_DIR)/makedevs
	make toolchain -C $(PACKAGES_DIR)/mkpasswd
	make toolchain -C $(PACKAGES_DIR)/m4
	make toolchain -C $(PACKAGES_DIR)/bison
	make toolchain -C $(PACKAGES_DIR)/gawk
	make toolchain -C $(PACKAGES_DIR)/binutils
	make toolchain -C $(PACKAGES_DIR)/gmp
	make toolchain -C $(PACKAGES_DIR)/mpfr
	make toolchain -C $(PACKAGES_DIR)/mpc
	make toolchain-initial -C $(PACKAGES_DIR)/gcc
	make sysroot -C $(PACKAGES_DIR)/linux
	make sysroot -C $(PACKAGES_DIR)/glibc
	make toolchain-final sysroot -C $(PACKAGES_DIR)/gcc
	make toolchain -C $(PACKAGES_DIR)/libtool
	make toolchain -C $(PACKAGES_DIR)/autoconf
	make toolchain -C $(PACKAGES_DIR)/automake
	make toolchain -C $(PACKAGES_DIR)/dosfstools
	make toolchain -C $(PACKAGES_DIR)/libconfuse
	make toolchain -C $(PACKAGES_DIR)/genimage
	make toolchain -C $(PACKAGES_DIR)/mtools
	# make toolchain -C $(PACKAGES_DIR)/patchelf
	make toolchain -C $(PACKAGES_DIR)/libxml2
	make toolchain -C $(PACKAGES_DIR)/gettext
	make toolchain -C $(PACKAGES_DIR)/expat
	# make toolchain -C $(PACKAGES_DIR)/libxml-parser-perl
	make toolchain -C $(PACKAGES_DIR)/intltool
	make toolchain -C $(PACKAGES_DIR)/flex
	make toolchain -C $(PACKAGES_DIR)/kmod

system:
	$(SCRIPTS_DIR)/system.sh

kernel:
	$(SCRIPTS_DIR)/kernel.sh

image:
	$(SCRIPTS_DIR)/image.sh

clean:
	rm -rf out

flash:
	sudo python2 $(SCRIPTS_DIR)/image-usb-stick $(IMAGES_DIR)/sdcard.img && sudo -k

download:
	wget -c -i wget-list -P $(SOURCES_DIR)
