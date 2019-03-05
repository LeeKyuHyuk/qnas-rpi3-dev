toolchain:
	$(STEP) "E2fsprogs 1.44.5"
	$(EXTRACT) $(SOURCES_DIR)/e2fsprogs-1.44.5.tar.gz $(BUILD_DIR)
	( cd $(BUILD_DIR)/e2fsprogs-1.44.5 && \
	PKG_CONFIG="$(TOOLS_DIR)/bin/pkg-config" \
	PKG_CONFIG_SYSROOT_DIR="/" \
	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
	PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
	PKG_CONFIG_LIBDIR="$(TOOLS_DIR)/lib/pkgconfig:$(TOOLS_DIR)/share/pkgconfig" \
	CFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	CPPFLAGS="-I$(TOOLS_DIR)/include" \
	CXXFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	LDFLAGS="-L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib" \
	./configure \
	--prefix=$(TOOLS_DIR) \
	--enable-shared \
	--disable-static \
	--disable-defrag \
	--disable-e2initrd-helper \
	--disable-fuse2fs \
	--disable-libblkid \
	--disable-libuuid \
	--disable-testio-debug \
	--enable-symlink-install \
	--enable-elf-shlibs )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/e2fsprogs-1.44.5
	make -j$(PARALLEL_JOBS) install install-libs -C $(BUILD_DIR)/e2fsprogs-1.44.5
	rm -rf $(BUILD_DIR)/e2fsprogs-1.44.5
