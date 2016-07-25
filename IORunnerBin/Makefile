# Makefile for IORunnerBin

MODULE_4_REAL_NAME=IORunner
$(MODULE_4_NAME)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(MODULE_4_NAME) -module-name $(MODULE_4_REAL_NAME) $($(OS)_SWIFTC_FLAGS) -enable-objc-interop \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

$(MODULE_4_NAME)_Src = $(MODULE_4_NAME)/Constants.swift $(MODULE_4_NAME)/AppExit.swift $(MODULE_4_NAME)/Arguments.swift $(MODULE_4_NAME)/ArgumentParser.swift \
	$(MODULE_4_NAME)/SignalHandler.swift $(MODULE_4_NAME)/DynamicLoader.swift $(MODULE_4_NAME)/AppWorker.swift $(MODULE_4_NAME)/Application.swift \
	$(MODULE_4_NAME)/main.swift
$(MODULE_4_NAME)_Obj = $(addsuffix .o, $(basename $($(MODULE_4_NAME)_Src)))
$(MODULE_4_NAME)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(MODULE_4_NAME)_Src))))

$(MODULE_4_NAME)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib \
	-I/usr/include
$(MODULE_4_NAME)_Linux_SHLIB_PATH = -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux -I/usr/include
$(MODULE_4_NAME)_SHLIB_PATH = $($(MODULE_4_NAME)_$(OS)_SHLIB_PATH)

$(MODULE_4_NAME)_Darwin_LFLAGS = $($(MODULE_4_NAME)_SHLIB_PATH) -arch x86_64 \
	-isysroot $(SDK) \
	-Xlinker -rpath -Xlinker -map -Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftmodule \
	-framework Foundation -framework $(MODULE_1_NAME) -framework $(MODULE_3_NAME) -framework $(MODULE_2_NAME)
$(MODULE_4_NAME)_Linux_LFLAGS = $($(MODULE_4_NAME)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm -shared
$(MODULE_4_NAME)_LFLAGS = $($(MODULE_4_NAME)_$(OS)_LFLAGS)

$(MODULE_4_NAME)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).bin $(BUILD_ROOT_DIR)/bin/$(MODULE_4_REAL_NAME)
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/bin/$(MODULE_4_REAL_NAME)

$(MODULE_4_NAME)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_4_NAME)

$(MODULE_4_NAME): $(MODULE_4_NAME)-modulecache $(MODULE_4_NAME).bin $(MODULE_4_NAME)-install

$(MODULE_4_NAME).bin: $($(MODULE_4_NAME)_Obj) $(MODULE_4_NAME).swiftmodule
	clang $($(MODULE_4_NAME)_Obj) $($(MODULE_4_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).bin

$(MODULE_4_NAME).swiftmodule:
	$(SWIFTC) -frontend $($(MODULE_4_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_4_NAME)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftmodule

$(MODULE_4_NAME)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/*.o $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/*.so \
	$(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/*.d $(MODULE_CACHE_PATH)/$(MODULE_4_NAME) \
	$(BUILD_ROOT_DIR)/lib/$(MODULE_4_NAME)* $(BUILD_ROOT_DIR)/lib/x86_64/$(MODULE_4_NAME)* \
	$(BUILD_ROOT_DIR)/bin/$(MODULE_4_NAME)* $(BUILD_ROOT_DIR)/bin/$(MODULE_4_REAL_NAME)*
	
$(MODULE_4_NAME)/%.o : $(MODULE_4_NAME)/%.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(MODULE_4_NAME)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(MODULE_4_NAME)_SWIFTC_FLAGS) \
	-o $@
	
