# Makefile for IORunnerInstaller

$(MODULE_NAME)Installer_CLANG_FLAGS = -arch x86_64 -fmacro-backtrace-limit=0 -std=gnu99 -Xclang -fmodule-implementation-of \
	-Xclang $(MODULE_NAME)Installer -Os -DBUILD_OS_$(OS)=1 -DAPP_NAME=\"$(MODULE_NAME)\" -DAPP_PACKAGE_NAME=\"$(MODULE_NAME)\" \
	-DAPP_VERSION=\"1.0.0\" -DINSTALLER_PACKAGE_NAME=\"$(MODULE_NAME)Installer\" \
	-I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer

$(MODULE_NAME)Installer_Src = $(MODULE_NAME)Installer/IOStringHelper.c $(MODULE_NAME)Installer/IORunnerInstaller.c \
	$(MODULE_NAME)Installer/IODirectory.c $(MODULE_NAME)Installer/IOProcessHelper.c
$(MODULE_NAME)Installer_Darwin_LFLAGS = $(addsuffix .o, $(basename $($(MODULE_NAME)Installer_Src)))

$(MODULE_NAME)Installer_Darwin_LFLAGS = -arch x86_64 \
	-isysroot $(SDK) -I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer \
	-Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker @executable_path
$(MODULE_NAME)Installer_Linux_LFLAGS = -arch x86_64 -lgcc_s -Xlinker -no_deduplicate -Xlinker -dependency_info \
	-fuse-ld=gold \
	-I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer \
	-Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker '$$ORIGIN'
$(MODULE_NAME)Installer_LFLAGS = $($(MODULE_NAME)Installer_$(OS)_LFLAGS)

$(MODULE_NAME)Installer-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer
	@chmod +x $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer

$(MODULE_NAME)Installer: $(MODULE_NAME)Installer.bin $(MODULE_NAME)Installer-install

$(MODULE_NAME)Installer.bin: $($(MODULE_NAME)Installer_Obj)
	clang $($(MODULE_NAME)Installer_Obj) $($(MODULE_NAME)Installer_LFLAGS) \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin

$(MODULE_NAME)Installer-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.bin \
	$(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer* $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/InstallDataEx.h \
	$(BUILD_ROOT_DIR)//$(MODULE_NAME)InstallData
	
$(MODULE_NAME)Installer/%.o : $(MODULE_NAME)Installer/%.c
	clang -x c $($(MODULE_NAME)Installer_CLANG_FLAGS) -c $< -o $@