toolchain:
	$(STEP) "Zlib 1.2.11"
	$(EXTRACT) $(SOURCES_DIR)/zlib-1.2.11.tar.xz $(BUILD_DIR)
	( cd $(BUILD_DIR)/zlib-1.2.11 && \
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
	--prefix=$(TOOLS_DIR) )
	make -j1 -C $(BUILD_DIR)/zlib-1.2.11
	make -j1 LDCONFIG=true install -C $(BUILD_DIR)/zlib-1.2.11
	rm -rf $(BUILD_DIR)/zlib-1.2.11
