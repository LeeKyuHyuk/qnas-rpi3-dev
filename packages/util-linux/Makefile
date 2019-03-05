toolchain:
	$(STEP) "Util-linux 2.33"
	$(EXTRACT) $(SOURCES_DIR)/util-linux-2.33.tar.xz $(BUILD_DIR)
	( cd $(BUILD_DIR)/util-linux-2.33 && \
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
	--without-python \
	--enable-libblkid \
	--enable-libmount \
	--enable-libuuid \
	--without-ncurses \
	--without-ncursesw \
	--without-tinfo \
	--disable-makeinstall-chown \
	--disable-agetty \
	--disable-chfn-chsh \
	--disable-chmem \
	--disable-login \
	--disable-lslogins \
	--disable-mesg \
	--disable-more \
	--disable-newgrp \
	--disable-nologin \
	--disable-nsenter \
	--disable-pg \
	--disable-rfkill \
	--disable-schedutils \
	--disable-setpriv \
	--disable-setterm \
	--disable-su \
	--disable-sulogin \
	--disable-tunelp \
	--disable-ul \
	--disable-unshare \
	--disable-uuidd \
	--disable-vipw \
	--disable-wall \
	--disable-wdctl \
	--disable-write \
	--disable-zramctl )
	make -j$(PARALLEL_JOBS) -C $(BUILD_DIR)/util-linux-2.33
	make -j$(PARALLEL_JOBS) install -C $(BUILD_DIR)/util-linux-2.33
	rm -rf $(BUILD_DIR)/util-linux-2.33
