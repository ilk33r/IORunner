# Makefile for IORunnerInstaller

$(MODULE_NAME)Installer_Darwin_CC = clang
$(MODULE_NAME)Installer_Linux_CC = clang
$(MODULE_NAME)Installer_CC = $($(MODULE_NAME)Installer_$(OS)_CC)

$(MODULE_NAME)Installer_Defines = -DBUILD_OS_$(OS)=1 -DAPP_NAME=\"$(MODULE_NAME)\" -DAPP_PACKAGE_NAME=\"$(MODULE_NAME)\" \
	-DAPP_VERSION=\"1.0.0\" -DINSTALLER_PACKAGE_NAME=\"$(MODULE_NAME)Installer\"

$(MODULE_NAME)Installer_Darwin_Paths = -I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer
$(MODULE_NAME)Installer_Linux_Paths = -I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer -I/usr/include -L/usr/lib -L/lib/x86_64-linux-gnu -I/usr/include/x86_64-linux-gnu
$(MODULE_NAME)Installer_Paths = $($(MODULE_NAME)Installer_$(OS)_Paths)

$(MODULE_NAME)Installer_Darwin_CC_FLAGS = -arch x86_64 -target x86_64-apple-macosx10.10 -fmacro-backtrace-limit=0 -std=gnu99 -Xclang -fmodule-implementation-of \
	-Xclang $(MODULE_NAME)Installer -Os
$(MODULE_NAME)Installer_Linux_CC_FLAGS = -std=gnu99 
$(MODULE_NAME)Installer_CC_FLAGS = $($(MODULE_NAME)Installer_$(OS)_CC_FLAGS) $($(MODULE_NAME)Installer_Defines) $($(MODULE_NAME)Installer_Paths)
	
$(MODULE_NAME)Installer_Src = $(MODULE_NAME)Installer/IOStringHelper.c $(MODULE_NAME)Installer/IORunnerInstaller.c \
	$(MODULE_NAME)Installer/IODirectory.c $(MODULE_NAME)Installer/IOProcessHelper.c
$(MODULE_NAME)Installer_Obj = $(addsuffix .o, $(basename $($(MODULE_NAME)Installer_Src)))

$(MODULE_NAME)Installer_Darwin_LFLAGS = $($(MODULE_NAME)Installer_Darwin_CC_FLAGS) \
	-isysroot $(SDK) \
	-Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker @executable_path
$(MODULE_NAME)Installer_Linux_LFLAGS = $($(MODULE_NAME)Installer_CC_FLAGS) -std=gnu99 \
	-static-libgcc -lc \
	-Xlinker -rpath -Xlinker '$$ORIGIN'
$(MODULE_NAME)Installer_LFLAGS = $($(MODULE_NAME)Installer_$(OS)_LFLAGS)

$(MODULE_NAME)Installer-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer
	@chmod +x $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer

$(MODULE_NAME)Installer: $(MODULE_NAME)Installer.bin $(MODULE_NAME)Installer-install

$(MODULE_NAME)Installer.bin: $($(MODULE_NAME)Installer_Obj)
	$($(MODULE_NAME)Installer_CC) $($(MODULE_NAME)Installer_LFLAGS) $($(MODULE_NAME)Installer_Obj) \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin

$(MODULE_NAME)Installer-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.bin \
	$(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer* $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/InstallDataEx.h \
	$(BUILD_ROOT_DIR)//$(MODULE_NAME)InstallData
	
$(MODULE_NAME)Installer/%.o : $(MODULE_NAME)Installer/%.c
	$($(MODULE_NAME)Installer_CC) -x c $($(MODULE_NAME)Installer_CC_FLAGS) -c $< -o $@