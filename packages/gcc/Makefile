toolchain-initial:
	$(STEP) "Gcc 8.3.0 - Initial"
	tar -Jxf $(SOURCES_DIR)/gcc-8.3.0.tar.xz -C $(BUILD_DIR) --exclude='libjava/*' --exclude='libgo/*'
	mkdir -pv $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	( cd $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build && \
	PKG_CONFIG="$(TOOLS_DIR)/bin/pkg-config" \
	PKG_CONFIG_SYSROOT_DIR="/" \
	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
	PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
	PKG_CONFIG_LIBDIR="$(TOOLS_DIR)/lib/pkgconfig:$(TOOLS_DIR)/share/pkgconfig" \
	CFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	CPPFLAGS="-I$(TOOLS_DIR)/include" \
	CXXFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	LDFLAGS="-L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib" \
	CFLAGS_FOR_TARGET="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os" \
	CXXFLAGS_FOR_TARGET="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os" \
	MAKEINFO=missing \
	$(BUILD_DIR)/gcc-8.3.0/configure \
	--prefix=$(TOOLS_DIR) \
	--disable-shared \
	--disable-static \
	--target=$(CONFIG_TARGET) \
	--with-sysroot=$(SYSROOT_DIR) \
	--enable-__cxa_atexit \
	--with-gnu-ld \
	--disable-libssp \
	--disable-multilib \
	--disable-decimal-float \
	--with-gmp=$(TOOLS_DIR) \
	--with-mpc=$(TOOLS_DIR) \
	--with-mpfr=$(TOOLS_DIR) \
	--disable-libquadmath \
	--enable-tls \
	--disable-libmudflap \
	--enable-threads \
	--without-isl \
	--without-cloog \
	--with-abi="lp64" \
	--with-cpu=cortex-a53 \
	--enable-languages=c \
	--without-headers \
	--disable-threads \
	--with-newlib \
	--disable-largefile \
	--disable-nls )
	make -j$(PARALLEL_JOBS) gcc_cv_libc_provides_ssp=yes all-gcc all-target-libgcc -C $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	make -j$(PARALLEL_JOBS) install-gcc install-target-libgcc -C $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	rm -rf $(BUILD_DIR)/gcc-8.3.0

toolchain-final:
	$(STEP) "Gcc 8.3.0 - Final"
	tar -Jxf $(SOURCES_DIR)/gcc-8.3.0.tar.xz -C $(BUILD_DIR) --exclude='libjava/*' --exclude='libgo/*'
	mkdir -pv $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	( cd $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build && \
	PKG_CONFIG="$(TOOLS_DIR)/bin/pkg-config" \
	PKG_CONFIG_SYSROOT_DIR="/" \
	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
	PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 \
	PKG_CONFIG_LIBDIR="$(TOOLS_DIR)/lib/pkgconfig:$(TOOLS_DIR)/share/pkgconfig" \
	CFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	CPPFLAGS="-I$(TOOLS_DIR)/include" \
	CXXFLAGS="-O2 -I$(TOOLS_DIR)/include" \
	LDFLAGS="-L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib" \
	CFLAGS_FOR_TARGET="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os" \
	CXXFLAGS_FOR_TARGET="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os" \
	MAKEINFO=missing \
	$(BUILD_DIR)/gcc-8.3.0/configure \
	--prefix=$(TOOLS_DIR) \
	--enable-shared \
	--disable-static \
	--target=$(CONFIG_TARGET) \
	--with-sysroot=$(SYSROOT_DIR) \
	--enable-__cxa_atexit \
	--with-gnu-ld \
	--disable-libssp \
	--disable-multilib \
	--disable-decimal-float \
	--with-gmp=$(TOOLS_DIR) \
	--with-mpc=$(TOOLS_DIR) \
	--with-mpfr=$(TOOLS_DIR) \
	--disable-libquadmath \
	--enable-tls \
	--disable-libmudflap \
	--enable-threads \
	--without-isl \
	--without-cloog \
	--with-abi="lp64" \
	--with-cpu=cortex-a53 \
	--enable-languages=c,c++ \
	--with-build-time-tools=$(TOOLS_DIR)/$(CONFIG_TARGET)/bin \
	--disable-libgomp )
	make -j$(PARALLEL_JOBS) gcc_cv_libc_provides_ssp=yes -C $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/gcc-8.3.0/gcc-initial-build
	rm -rf $(BUILD_DIR)/gcc-8.3.0

sysroot:
	if [[ ! -e $(TOOLS_DIR)/bin/$(CONFIG_TARGET)-cc ]] ; then \
		ln -f $(TOOLS_DIR)/bin/$(CONFIG_TARGET)-gcc $(TOOLS_DIR)/bin/$(CONFIG_TARGET)-cc ; \
	fi
	cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/libgcc_s* $(SYSROOT_DIR)/lib/
	cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/libatomic* $(SYSROOT_DIR)/lib/
	for i in libstdc++ ; do \
		cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/$${i}.a $(SYSROOT_DIR)/usr/lib/ ; \
		cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/$${i}.la $(SYSROOT_DIR)/usr/lib/ ; \
		cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/$${i}.so* $(SYSROOT_DIR)/usr/lib/ ; \
	done

system:
	cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/libgcc_s* $(ROOTFS_DIR)/lib/
	cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/libatomic* $(ROOTFS_DIR)/lib/
	mkdir -pv $(ROOTFS_DIR)/usr/lib
	for i in libstdc++ ; do \
		cp -dpfv $(TOOLS_DIR)/$(CONFIG_TARGET)/lib*/$${i}.so* $(ROOTFS_DIR)/usr/lib/ ; \
	done
