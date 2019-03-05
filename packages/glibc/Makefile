sysroot:
	$(STEP) "Glibc 2.28"
	$(EXTRACT) $(SOURCES_DIR)/glibc-2.28.tar.xz $(BUILD_DIR)
	mkdir -pv $(BUILD_DIR)/glibc-2.28/gilbc-build
	( cd $(BUILD_DIR)/glibc-2.28/gilbc-build && \
	AR="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-ar" \
	AS="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-as" \
	LD="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-ld" \
	GCC="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-gcc" \
	CPP="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-cpp" \
	RANLIB="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-ranlib" \
	READELF="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-readelf" \
	STRIP="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-strip" \
	OBJCOPY="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-objcopy" \
	OBJDUMP="$(TOOLS_DIR)/bin/$(CONFIG_TARGET)-objdump" \
	PKG_CONFIG="$(TOOLS_DIR)/bin/pkg-config" \
	ac_cv_path_BASH_SHELL=/bin/bash \
	libc_cv_forced_unwind=yes \
	libc_cv_ssp=no \
	ac_cv_prog_MAKE="make -j$(PARALLEL_JOBS)" \
	$(BUILD_DIR)/glibc-2.28/configure \
	--target=$(CONFIG_TARGET) \
	--host=$(CONFIG_TARGET) \
	--build=x86_64-pc-linux-gnu \
	--prefix=/usr \
	--enable-shared \
	--without-cvs \
	--disable-profile \
	--without-gd \
	--enable-obsolete-rpc \
	--enable-kernel=4.14 \
	--with-headers=$(SYSROOT_DIR)/usr/include )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/glibc-2.28/gilbc-build
	make -j$(PARALLEL_JOBS) install_root=$(SYSROOT_DIR) install -C $(BUILD_DIR)/glibc-2.28/gilbc-build
	rm -rf $(BUILD_DIR)/glibc-2.28
