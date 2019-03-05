toolchain:
	$(STEP) "mkpasswd"
	mkdir -pv $(BUILD_DIR)/mkpasswd
	gcc -O2 -I$(TOOLS_DIR)/include -L$(TOOLS_DIR)/lib -Wl,-rpath,$(TOOLS_DIR)/lib $(PACKAGES_DIR)/mkpasswd/mkpasswd.c $(PACKAGES_DIR)/mkpasswd/utils.c -o $(BUILD_DIR)/mkpasswd/mkpasswd -lcrypt
	install -Dv -m 755 $(BUILD_DIR)/mkpasswd/mkpasswd $(TOOLS_DIR)/bin/mkpasswd
	rm -rf $(BUILD_DIR)/mkpasswd
