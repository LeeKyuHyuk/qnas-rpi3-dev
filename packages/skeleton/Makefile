toolchain:
	$(STEP) "[1/37] Create toolchain directory."
	rm -rf $(BUILD_DIR) $(TOOLS_DIR)
	mkdir -pv $(BUILD_DIR) $(TOOLS_DIR)
	ln -svf . $(TOOLS_DIR)/usr

sysroot:
	$(STEP) "[2/37] Create the sysroot directory"
	mkdir -pv $(SYSROOT_DIR)
	ln -svf . $(SYSROOT_DIR)/usr
	if [[ "$(CONFIG_LINUX_ARCH)" = "arm" ]] ; then \
	  ln -snvf lib $(SYSROOT_DIR)/lib32 ; \
	fi
	if [[ "$(CONFIG_LINUX_ARCH)" = "arm64" ]] ; then \
	  ln -snvf lib $(SYSROOT_DIR)/lib64 ; \
	fi
