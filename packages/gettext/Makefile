toolchain:
	$(STEP) "Gettext 0.19.8.1"
	$(EXTRACT) $(SOURCES_DIR)/gettext-0.19.8.1.tar.xz $(BUILD_DIR)
	sed -i -e '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/examples$$//' $(BUILD_DIR)/gettext-0.19.8.1/gettext-tools/Makefile.in
	sed -i -e '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/tests$$//' $(BUILD_DIR)/gettext-0.19.8.1/gettext-runtime/Makefile.in
	( cd $(BUILD_DIR)/gettext-0.19.8.1 && \
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
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-rpath \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/gettext-0.19.8.1
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/gettext-0.19.8.1
	rm -rf $(BUILD_DIR)/gettext-0.19.8.1
