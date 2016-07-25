# Makefile for IORunnerInstaller

$(MODULE_NAME)Installer_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) -DInstallDataGenerated=1 \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_NAME)Installer -module-name $(MODULE_NAME)Installer $($(OS)_SWIFTC_FLAGS) -enable-objc-interop \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks \
	-I $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer \
	-import-objc-header $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer-Bridging-Header.h

$(MODULE_NAME)Installer_Src = $(MODULE_NAME)Installer/Constants.swift $(MODULE_NAME)Installer/ConfigFile.swift \
	$(MODULE_NAME)Installer/Installer.swift \
	$(MODULE_NAME)Installer/main.swift
$(MODULE_NAME)Installer_Obj = $(addsuffix .o, $(basename $($(MODULE_NAME)Installer_Src)))
$(MODULE_NAME)Installer_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_NAME)Installer_Src))))

$(MODULE_NAME)Installer_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib \
	-I/usr/include -I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer \
	-L$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer
$(MODULE_NAME)Installer_Linux_SHLIB_PATH = -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux -I/usr/include \
	-I$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer -L$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer
$(MODULE_NAME)Installer_SHLIB_PATH = $($(MODULE_NAME)Installer_$(OS)_SHLIB_PATH)

$(MODULE_NAME)Installer_Darwin_LFLAGS = $($(MODULE_NAME)Installer_SHLIB_PATH) -arch x86_64 \
	-isysroot $(SDK) -lInstallData \
	-Xlinker -rpath -Xlinker -map -Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.swiftmodule \
	-framework Foundation -framework $(MODULE_3_NAME)
$(MODULE_NAME)Installer_Linux_LFLAGS = $($(MODULE_NAME)Installer_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm -lFoundation -shared
$(MODULE_NAME)Installer_LFLAGS = $($(MODULE_NAME)Installer_$(OS)_LFLAGS)

$(MODULE_NAME)Installer_Darwin_ASSETS_LFLAGS = $($(MODULE_NAME)Installer_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-install_name $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/libInstallData.dylib \
	-isysroot -shared -stdlib=libc++ \
	-Xlinker -rpath -Xlinker -map -Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path
$(MODULE_NAME)Installer_Linux_ASSETS_LFLAGS = $($(MODULE_NAME)Installer_SHLIB_PATH) -arch x86_64 -shared -stdlib=libc++ -Wl,-rpath,/absolute/path
$(MODULE_NAME)Installer_ASSETS_LFLAGS = $($(MODULE_NAME)Installer_$(OS)_ASSETS_LFLAGS)

$(MODULE_NAME)Installer-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer
	@chmod +x $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer

$(MODULE_NAME)Installer-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_NAME)Installer
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Bin/Constants.swift $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/

$(MODULE_NAME)Installer: $(MODULE_NAME)Installer-modulecache $(MODULE_NAME)Installer.bin $(MODULE_NAME)Installer-install

$(MODULE_NAME)Installer.bin: $($(MODULE_NAME)Installer_Obj) $(MODULE_NAME)Installer.swiftmodule $(MODULE_NAME)Installer/InstallData.so
	cp $(MODULE_NAME)Installer/InstallData.so $(MODULE_NAME)Installer/libInstallData.dylib
	clang $($(MODULE_NAME)Installer_Obj) $($(MODULE_NAME)Installer_LFLAGS) \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.bin

$(MODULE_NAME)Installer.swiftmodule:
	$(SWIFTC) -frontend $($(MODULE_NAME)Installer_SWIFTC_FLAGS) -emit-module $($(MODULE_NAME)Installer_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/$(MODULE_NAME)Installer.swiftmodule

$(MODULE_NAME)Installer-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.o $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.d $(MODULE_CACHE_PATH)/$(MODULE_NAME)Installer \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_NAME)Installer* $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/*.bin \
	$(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer* $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/InstallDataEx.h \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/Constants.swift $(BUILD_ROOT_DIR)/$(MODULE_NAME)Installer \
	$(BUILD_ROOT_DIR)/$(MODULE_NAME)InstallData $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/libInstallData.dylib

$(MODULE_NAME)Installer/InstallData.so : $(MODULE_NAME)Installer/InstallData.c
	clang -c $(SOURCE_ROOT_DIR)/$< $($(MODULE_NAME)Installer_ASSETS_LFLAGS) -o $(SOURCE_ROOT_DIR)/$@

$(MODULE_NAME)Installer/Constants.o : $(MODULE_NAME)Installer/Constants.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(MODULE_NAME)Installer_Src)) -primary-file $(MODULE_NAME)Installer/Constants.swift \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$(MODULE_NAME)Installer/Constants.o) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$(MODULE_NAME)Installer/Constants.o) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$(MODULE_NAME)Installer/Constants.swift) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$(MODULE_NAME)Installer/Constants.swift) \
	$($(MODULE_NAME)Installer_SWIFTC_FLAGS) \
	-o $(MODULE_NAME)Installer/Constants.o
	
$(MODULE_NAME)Installer/%.o : $(MODULE_NAME)Installer/%.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(MODULE_NAME)Installer_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_NAME)Installer_SWIFTC_FLAGS) \
	-o $@
	
