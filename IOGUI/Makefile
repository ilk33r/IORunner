# Makefile for IOGUI

$(MODULE_3_NAME)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_3_NAME) -module-name $(MODULE_3_NAME) $($(OS)_SWIFTC_FLAGS) -enable-objc-interop \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks \
	-import-objc-header $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME)-Bridging-Header.h

$(MODULE_3_NAME)_Src = $(MODULE_3_NAME)/TitleAndFooterWidget.swift $(MODULE_3_NAME)/AppInfoWidget.swift $(MODULE_3_NAME)/MenuWidget.swift \
	$(MODULE_3_NAME)/ModulesWidget.swift $(MODULE_3_NAME)/PopupWidget.swift \
	$(MODULE_3_NAME)/BackgroundWidget.swift $(MODULE_3_NAME)/InputPopupWidget.swift $(MODULE_3_NAME)/GUITypes.swift
$(MODULE_3_NAME)_Obj = $(addsuffix .o, $(basename $($(MODULE_3_NAME)_Src)))
$(MODULE_3_NAME)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_3_NAME)_Src))))

$(MODULE_3_NAME)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib \
	-I/usr/include
$(MODULE_3_NAME)_Linux_SHLIB_PATH = -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux -I/usr/include
$(MODULE_3_NAME)_SHLIB_PATH = $($(MODULE_3_NAME)_$(OS)_SHLIB_PATH)

$(MODULE_3_NAME)_Darwin_LFLAGS = $($(MODULE_3_NAME)_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) -lncurses \
	-install_name $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/$(MODULE_3_NAME) -Xlinker -rpath \
	-Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks -stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule -single_module \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation
$(MODULE_3_NAME)_Linux_LFLAGS = $($(MODULE_3_NAME)_SHLIB_PATH) -lncurses -lswiftCore -lswiftGlibc -ldl -lm -shared
$(MODULE_3_NAME)_LFLAGS = $($(MODULE_3_NAME)_$(OS)_LFLAGS)

$(MODULE_3_NAME)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).so $(BUILD_ROOT_DIR)/lib/
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/lib/$(MODULE_3_NAME).so
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).so $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/$(MODULE_3_NAME)
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftdoc $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Modules/$(MODULE_3_NAME).swiftmodule/x86_64.swiftdoc
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Modules/$(MODULE_3_NAME).swiftmodule/x86_64.swiftmodule
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/module.modulemap $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Modules

$(MODULE_3_NAME)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_3_NAME)
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Modules
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Headers
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/A/Modules/$(MODULE_3_NAME).swiftmodule
	@ln -sf Versions/Current/Modules $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Modules
	@ln -sf A $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Versions/Current
	@ln -sf Versions/Current/Headers $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/Headers
	@ln -sf Versions/Current/$(MODULE_3_NAME) $(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME).framework/$(MODULE_3_NAME)

$(MODULE_3_NAME): $(MODULE_3_NAME)-modulecache $(MODULE_3_NAME).so $(MODULE_3_NAME)-install

$(MODULE_3_NAME).so: $($(MODULE_3_NAME)_Obj) $(MODULE_3_NAME).swiftmodule
	clang $($(MODULE_3_NAME)_Obj) $($(MODULE_3_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).so

$(MODULE_3_NAME).swiftmodule:
	$(SWIFTC) -frontend $($(MODULE_3_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_3_NAME)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule

$(MODULE_3_NAME)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.d $(MODULE_CACHE_PATH)/$(MODULE_3_NAME) \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_3_NAME)* $(BUILD_ROOT_DIR)/lib/x86_64/$(MODULE_3_NAME)* \
	$(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME)*
	
$(MODULE_3_NAME)/%.o : $(MODULE_3_NAME)/%.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(MODULE_3_NAME)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_3_NAME)_SWIFTC_FLAGS) \
	-o $@
	
