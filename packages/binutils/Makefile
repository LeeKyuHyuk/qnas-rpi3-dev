toolchain:
	$(STEP) "Binutils 2.31.1"
	$(EXTRACT) $(SOURCES_DIR)/binutils-2.31.1.tar.xz $(BUILD_DIR)
	( cd $(BUILD_DIR)/binutils-2.31.1 && \
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
	--disable-shared \
	--enable-static \
	--disable-multilib \
	--disable-werror \
	--target=$(CONFIG_TARGET) \
	--with-sysroot=$(SYSROOT_DIR) \
	--enable-poison-system-directories \
	--disable-sim \
	--disable-gdb )
	make -j$(PARALLEL_JOBS) MAKEINFO=true -C $(BUILD_DIR)/binutils-2.31.1
	make -j$(PARALLEL_JOBS) MAKEINFO=true install -C $(BUILD_DIR)/binutils-2.31.1
	rm -rf $(BUILD_DIR)/binutils-2.31.1
