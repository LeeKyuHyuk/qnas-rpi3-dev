toolchain:
	$(STEP) "[1/37] Create toolchain directory."
	rm -rf $(BUILD_DIR) $(TOOLS_DIR)
	mkdir -pv $(BUILD_DIR) $(TOOLS_DIR)
	ln -svf . $(TOOLS_DIR)/usr

sysroot:
	$(STEP) "[2/37] Create the sysroot directory"
	rm -rf $(SYSROOT_DIR)
	mkdir -pv $(SYSROOT_DIR)
	ln -svf . $(SYSROOT_DIR)/usr
	if [[ "$(CONFIG_LINUX_ARCH)" = "arm" ]] ; then \
	  ln -snvf lib $(SYSROOT_DIR)/lib32 ; \
	fi
	if [[ "$(CONFIG_LINUX_ARCH)" = "arm64" ]] ; then \
	  ln -snvf lib $(SYSROOT_DIR)/lib64 ; \
	fi

system:
	rm -rf $(ROOTFS_DIR)
	mkdir -pv $(ROOTFS_DIR)/dev
	ln -svf ../proc/self/fd $(ROOTFS_DIR)/dev/fd
	ln -svf ../proc/self/fd/2 $(ROOTFS_DIR)/dev/stderr
	ln -svf ../proc/self/fd/0 $(ROOTFS_DIR)/dev/stdin
	ln -svf ../proc/self/fd/1 $(ROOTFS_DIR)/dev/stdout
	mkdir -pv $(ROOTFS_DIR)/etc/profile.d
	cp -v $(PACKAGES_DIR)/skeleton/group $(ROOTFS_DIR)/etc/group
	cp -v $(PACKAGES_DIR)/skeleton/hosts $(ROOTFS_DIR)/etc/hosts
	ln -svf ../proc/self/mounts $(ROOTFS_DIR)/etc/mtab
	cp -v $(PACKAGES_DIR)/skeleton/passwd $(ROOTFS_DIR)/etc/passwd
	cp -v $(PACKAGES_DIR)/skeleton/profile $(ROOTFS_DIR)/etc/profile
	cp -v $(PACKAGES_DIR)/skeleton/umask.sh $(ROOTFS_DIR)/etc/profile.d/umask.sh
	cp -v $(PACKAGES_DIR)/skeleton/protocols $(ROOTFS_DIR)/etc/protocols
	ln -svf ../tmp/resolv.conf $(ROOTFS_DIR)/etc/resolv.conf
	cp -v $(PACKAGES_DIR)/skeleton/services $(ROOTFS_DIR)/etc/services
	cp -v $(PACKAGES_DIR)/skeleton/shadow $(ROOTFS_DIR)/etc/shadow
	mkdir -pv $(ROOTFS_DIR)/media
	mkdir -pv $(ROOTFS_DIR)/mnt
	mkdir -pv $(ROOTFS_DIR)/opt
	mkdir -pv $(ROOTFS_DIR)/proc
	mkdir -pv $(ROOTFS_DIR)/root
	mkdir -pv $(ROOTFS_DIR)/run
	mkdir -pv $(ROOTFS_DIR)/sys
	mkdir -pv $(ROOTFS_DIR)/tmp
	mkdir -pv $(ROOTFS_DIR)/usr/bin
	mkdir -pv $(ROOTFS_DIR)/usr/lib
	mkdir -pv $(ROOTFS_DIR)/usr/sbin
	install -d -m 0755 $(ROOTFS_DIR)/bin
	install -d -m 0755 $(ROOTFS_DIR)/sbin
	install -d -m 0755 $(ROOTFS_DIR)/lib
	ln -snfv lib $(ROOTFS_DIR)/lib64
	ln -snfv lib $(ROOTFS_DIR)/usr/lib64
	sed -i -e 's,@PATH@,"/bin:/sbin:/usr/bin:/usr/sbin",' $(ROOTFS_DIR)/etc/profile
