toolchain:
	$(STEP) "Pkgconf 1.5.3"
	$(EXTRACT) $(SOURCES_DIR)/pkgconf-1.5.3.tar.xz $(BUILD_DIR)
	patch -Np1 -i $(PACKAGES_DIR)/pkgconf/Only-prefix-with-the-sysroot-a-subset-of-variables.patch -d $(BUILD_DIR)/pkgconf-1.5.3
	patch -Np1 -i $(PACKAGES_DIR)/pkgconf/Revert-main-assume-modversion-insted-of-version-if-o.patch -d $(BUILD_DIR)/pkgconf-1.5.3
	( cd $(BUILD_DIR)/pkgconf-1.5.3 && \
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
	--disable-static )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/pkgconf-1.5.3
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/pkgconf-1.5.3
	install -m 0755 -D $(PACKAGES_DIR)/pkgconf/pkg-config.in $(TOOLS_DIR)/bin/pkg-config
	sed -i -e 's,@STAGING_SUBDIR@,$(CONFIG_TARGET)/sysroot,g' $(TOOLS_DIR)/bin/pkg-config
	sed -i -e 's,@STATIC@,,' $(TOOLS_DIR)/bin/pkg-config
	rm -rf $(BUILD_DIR)/pkgconf-1.5.3
