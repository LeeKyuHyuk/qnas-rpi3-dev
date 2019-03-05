toolchain:
	$(STEP) "libxml2 2.9.9"
	$(EXTRACT) $(SOURCES_DIR)/libxml2-2.9.9.tar.gz $(BUILD_DIR)
	( cd $(BUILD_DIR)/libxml2-2.9.9 && \
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
	--without-zlib \
	--without-lzma \
	--without-python )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/libxml2-2.9.9
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/libxml2-2.9.9
	rm -rf $(BUILD_DIR)/libxml2-2.9.9
