# Makefile for IOGUI

$(MODULE_3_NAME)_SWIFT_Darwin_DEFINES = -D DO_NOT_USE_CURSES_ASCII
$(MODULE_3_NAME)_SWIFT_Linux_DEFINES = -D ONLY_USE_CURSES_ASCII
$(MODULE_3_NAME)_SWIFT_DEFINES = $($(MODULE_3_NAME)_SWIFT_$(OS)_DEFINES)

$(MODULE_3_NAME)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) $($(MODULE_3_NAME)_SWIFT_DEFINES) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_3_NAME) -module-name $(MODULE_3_NAME) $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks \
	-import-objc-header $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME)-Bridging-Header.h
	
# -enable-objc-interop

$(MODULE_3_NAME)_Src = $(MODULE_3_NAME)/TitleAndFooterWidget.swift $(MODULE_3_NAME)/AppInfoWidget.swift $(MODULE_3_NAME)/MenuWidget.swift \
	$(MODULE_3_NAME)/ModulesWidget.swift $(MODULE_3_NAME)/PopupWidget.swift \
	$(MODULE_3_NAME)/BackgroundWidget.swift $(MODULE_3_NAME)/InputPopupWidget.swift $(MODULE_3_NAME)/GUITypes.swift $(MODULE_3_NAME)/CursesHelper.swift
$(MODULE_3_NAME)_Obj = $(addsuffix .o, $(basename $($(MODULE_3_NAME)_Src)))
$(MODULE_3_NAME)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_3_NAME)_Src))))

$(MODULE_3_NAME)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs)
$(MODULE_3_NAME)_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
		-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
		-L$(BUILD_ROOT_DIR)/lib -I/usr/include
$(MODULE_3_NAME)_SHLIB_PATH = $($(MODULE_3_NAME)_$(OS)_SHLIB_PATH)

$(MODULE_3_NAME)_Darwin_LFLAGS = $($(MODULE_3_NAME)_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) -lncurses \
	-install_name @executable_path/../frameworks/$(MODULE_3_NAME).framework/Versions/A/$(MODULE_3_NAME) \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation
$(MODULE_3_NAME)_Linux_LFLAGS = $($(MODULE_3_NAME)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \
	-lncurses \
	-shared -flto -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib/x86_64/$(MODULE_3_NAME).swiftmodule' \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	-Xlinker -rpath -Xlinker '/usr/lib64' \
	-Xlinker -rpath -Xlinker '/usr/lib' \
	-Xlinker -rpath -Xlinker '/usr/local/lib64' \
	-Xlinker -rpath -Xlinker '/usr/local/lib' \
	$(SWIFT_libs)/x86_64/swift_end.o
$(MODULE_3_NAME)_LFLAGS = $($(MODULE_3_NAME)_$(OS)_LFLAGS)

$(MODULE_3_NAME)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).so $(BUILD_ROOT_DIR)/lib/lib$(MODULE_3_NAME).so
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/lib/lib$(MODULE_3_NAME).so
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
	$(CLANG) $($(MODULE_3_NAME)_Obj) $($(MODULE_3_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).so

$(MODULE_3_NAME).swiftmodule:
	$(SWIFT) -frontend $($(MODULE_3_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_3_NAME)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/$(MODULE_3_NAME).swiftmodule

$(MODULE_3_NAME)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.o $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/*.d $(MODULE_CACHE_PATH)/$(MODULE_3_NAME) \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_3_NAME)* $(BUILD_ROOT_DIR)/lib/lib$(MODULE_3_NAME)* $(BUILD_ROOT_DIR)/lib/x86_64/$(MODULE_3_NAME)* \
	$(BUILD_ROOT_DIR)/frameworks/$(MODULE_3_NAME)*
	
$(MODULE_3_NAME)/%.o : $(MODULE_3_NAME)/%.swift
	$(SWIFT) -frontend -c $(subst $<,,$($(MODULE_3_NAME)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_3_NAME)_SWIFTC_FLAGS) \
	-o $@
	
