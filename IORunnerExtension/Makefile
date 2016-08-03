# Makefile for IORunnerExtension

$(MODULE_2_NAME)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_2_NAME) -module-name $(MODULE_2_NAME) $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks
	
# -enable-objc-interop

$(MODULE_2_NAME)_Src = $(MODULE_2_NAME)/Logger.swift $(MODULE_2_NAME)/AppHandlers.swift
$(MODULE_2_NAME)_Obj = $(addsuffix .o, $(basename $($(MODULE_2_NAME)_Src)))
$(MODULE_2_NAME)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_2_NAME)_Src))))

$(MODULE_2_NAME)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-L ../lib -F ../frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib
$(MODULE_2_NAME)_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux \
		-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
		-L$(BUILD_ROOT_DIR)/lib -I/usr/include -L../lib
$(MODULE_2_NAME)_SHLIB_PATH = $($(MODULE_2_NAME)_$(OS)_SHLIB_PATH)

$(MODULE_2_NAME)_Darwin_LFLAGS = $($(MODULE_2_NAME)_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name @executable_path/../frameworks/$(MODULE_2_NAME).framework/Versions/A/$(MODULE_2_NAME) -Xlinker -rpath \
	-Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks -stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../lib/x86_64/$(MODULE_2_NAME).swiftmodule \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework $(MODULE_1_NAME) -framework Foundation
$(MODULE_2_NAME)_Linux_LFLAGS = $($(MODULE_2_NAME)_SHLIB_PATH) -lswiftCore -lswiftGlibc -lm -ldl -lpthread -licui18n -licuuc -lFoundation -lbsd \
	-l$(MODULE_1_NAME) \
	-shared -fuse-ld=gold \
	-Xlinker -rpath \
	-Xlinker $(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux \
	-Xlinker -rpath \
	-Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftmodule \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib/x86_64/$(MODULE_2_NAME).swiftmodule' \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux/x86_64/swift_end.o
	
$(MODULE_2_NAME)_LFLAGS = $($(MODULE_2_NAME)_$(OS)_LFLAGS)

$(MODULE_2_NAME)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).so $(BUILD_ROOT_DIR)/lib/lib$(MODULE_2_NAME).so
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/lib/lib$(MODULE_2_NAME).so
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).so $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/$(MODULE_2_NAME)
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftdoc $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Modules/$(MODULE_2_NAME).swiftmodule/x86_64.swiftdoc
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftmodule $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Modules/$(MODULE_2_NAME).swiftmodule/x86_64.swiftmodule
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/module.modulemap $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Modules

$(MODULE_2_NAME)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_2_NAME)
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Modules
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Headers
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/A/Modules/$(MODULE_2_NAME).swiftmodule
	@ln -sf Versions/Current/Modules $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Modules
	@ln -sf A $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Versions/Current
	@ln -sf Versions/Current/Headers $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/Headers
	@ln -sf Versions/Current/$(MODULE_2_NAME) $(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME).framework/$(MODULE_2_NAME)

$(MODULE_2_NAME): $(MODULE_2_NAME)-modulecache $(MODULE_2_NAME).so $(MODULE_2_NAME)-install

$(MODULE_2_NAME).so: $($(MODULE_2_NAME)_Obj) $(MODULE_2_NAME).swiftmodule
	$(CLANG) $($(MODULE_2_NAME)_Obj) $($(MODULE_2_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).so

$(MODULE_2_NAME).swiftmodule:
	$(SWIFT) -frontend $($(MODULE_2_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_2_NAME)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/$(MODULE_2_NAME).swiftmodule

$(MODULE_2_NAME)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/*.o $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/*.d $(MODULE_CACHE_PATH)/$(MODULE_2_NAME) \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_2_NAME)* $(BUILD_ROOT_DIR)/lib/lib$(MODULE_2_NAME)* $(BUILD_ROOT_DIR)/lib/x86_64/$(MODULE_2_NAME)* \
	$(BUILD_ROOT_DIR)/frameworks/$(MODULE_2_NAME)*
	
$(MODULE_2_NAME)/%.o : $(MODULE_2_NAME)/%.swift
	$(SWIFT) -frontend -c $(subst $<,,$($(MODULE_2_NAME)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_2_NAME)_SWIFTC_FLAGS) \
	-o $@
	
