toolchain:
	$(STEP) "makedevs"
	mkdir -pv $(BUILD_DIR)/makedevs
	gcc -O2 -I$(TOOLS_DIR)/include $(PACKAGES_DIR)/makedevs/makedevs.c -o $(BUILD_DIR)/makedevs/makedevs -L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib
	install -Dv -m 755 $(BUILD_DIR)/makedevs/makedevs $(TOOLS_DIR)/bin/makedevs
	rm -rf $(BUILD_DIR)/makedevs
