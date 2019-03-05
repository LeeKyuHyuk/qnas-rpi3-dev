toolchain:
	$(STEP) "libcap 2.26"
	$(EXTRACT) $(SOURCES_DIR)/libcap-2.26.tar.xz $(BUILD_DIR)
	PKG_CONFIG="$(TOOLS_DIR)/bin/pkg-config" \
	PKG_CONFIG_SYSROOT_DIR="/" \
	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
	PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
	PKG_CONFIG_LIBDIR="$(TOOLS_DIR)/lib/pkgconfig:$(TOOLS_DIR)/share/pkgconfig" \
	CFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	CPPFLAGS="-I$(TOOLS_DIR)/include" \
	CXXFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	LDFLAGS="-L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib" \
	make -j$(PARALLEL_JOBS) RAISE_SETFCAP=no -C $(BUILD_DIR)/libcap-2.26
	make -j$(PARALLEL_JOBS) DESTDIR=$(TOOLS_DIR) RAISE_SETFCAP=no prefix=/usr lib=lib install -C $(BUILD_DIR)/libcap-2.26
	rm -rf $(BUILD_DIR)/libcap-2.26
