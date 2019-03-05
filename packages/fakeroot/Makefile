toolchain:
	$(STEP) "Fakeroot 1.23"
	$(EXTRACT) $(SOURCES_DIR)/fakeroot_1.23.orig.tar.xz $(BUILD_DIR)
	( cd $(BUILD_DIR)/fakeroot-1.23 && \
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
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/fakeroot-1.23
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/fakeroot-1.23
	rm -rf $(BUILD_DIR)/fakeroot-1.23
