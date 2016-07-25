# Makefile for IOIni

$(MODULE_1_NAME)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_1_NAME) -module-name $(MODULE_1_NAME) $($(OS)_SWIFTC_FLAGS) -enable-objc-interop

$(MODULE_1_NAME)_Src = $(MODULE_1_NAME)/Error.swift $(MODULE_1_NAME)/parseINI.swift
$(MODULE_1_NAME)_Obj = $(addsuffix .o, $(basename $($(MODULE_1_NAME)_Src)))
$(MODULE_1_NAME)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_1_NAME)_Src))))

$(MODULE_1_NAME)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10
$(MODULE_1_NAME)_Linux_SHLIB_PATH = -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux
$(MODULE_1_NAME)_SHLIB_PATH = $($(MODULE_1_NAME)_$(OS)_SHLIB_PATH)

$(MODULE_1_NAME)_Darwin_LFLAGS = $(INI_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/$(MODULE_1_NAME) -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks -stdlib=libc++ \
	-Xlinker -no_deduplicate \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftmodule -single_module \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation
$(MODULE_1_NAME)_Linux_LFLAGS = $($(MODULE_1_NAME)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm -lFoundation -shared
$(MODULE_1_NAME)_LFLAGS = $($(MODULE_1_NAME)_$(OS)_LFLAGS)

$(MODULE_1_NAME)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).so $(BUILD_ROOT_DIR)/lib/
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/lib/$(MODULE_1_NAME).so
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).so $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/$(MODULE_1_NAME)
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftdoc $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Modules/$(MODULE_1_NAME).swiftmodule/x86_64.swiftdoc
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftmodule $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Modules/$(MODULE_1_NAME).swiftmodule/x86_64.swiftmodule
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/module.modulemap $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Modules

$(MODULE_1_NAME)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_1_NAME)
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Modules
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Headers
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/A/Modules/$(MODULE_1_NAME).swiftmodule
	@ln -sf Versions/Current/Modules $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Modules
	@ln -sf A $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Versions/Current
	@ln -sf Versions/Current/Headers $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/Headers
	@ln -sf Versions/Current/$(MODULE_1_NAME) $(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME).framework/$(MODULE_1_NAME)

$(MODULE_1_NAME): $(MODULE_1_NAME)-modulecache $(MODULE_1_NAME).so $(MODULE_1_NAME)-install

$(MODULE_1_NAME).so: $($(MODULE_1_NAME)_Obj) $(MODULE_1_NAME).swiftmodule
	clang $($(MODULE_1_NAME)_Obj) $($(MODULE_1_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).so

$(MODULE_1_NAME).swiftmodule:
	$(SWIFTC) -frontend $($(MODULE_1_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_1_NAME)_Modules) -parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/$(MODULE_1_NAME).swiftmodule

$(MODULE_1_NAME)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/*.o $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/*.d $(MODULE_CACHE_PATH)/$(MODULE_1_NAME) \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_1_NAME)* $(BUILD_ROOT_DIR)/lib/x86_64/$(MODULE_1_NAME)* \
	$(BUILD_ROOT_DIR)/frameworks/$(MODULE_1_NAME)*
	
$(MODULE_1_NAME)/%.o : $(MODULE_1_NAME)/%.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(MODULE_1_NAME)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_1_NAME)_SWIFTC_FLAGS) \
	-o $@
