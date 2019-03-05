sysroot:
	$(STEP) "Linux Headers"
	$(EXTRACT) $(SOURCES_DIR)/raspberrypi-kernel_1.20190215-1.tar.gz $(BUILD_DIR)
	make -j$(PARALLEL_JOBS) ARCH=$(CONFIG_LINUX_ARCH) INSTALL_HDR_PATH=$(SYSROOT_DIR)/usr headers_install -C $(BUILD_DIR)/linux-raspberrypi-kernel_1.20190215-1
	rm -rf $(BUILD_DIR)/linux-raspberrypi-kernel_1.20190215-1
