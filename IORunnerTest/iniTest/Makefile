# Makefile for iniTest

$(TEST_MODULE_1)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/$(TEST_MODULE_1) -module-name $(TEST_MODULE_1) $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks
	
$(TEST_MODULE_1)_Src = $(TEST_MODULE_1)/main.swift
$(TEST_MODULE_1)_Obj = $(addsuffix .o, $(basename $($(TEST_MODULE_1)_Src)))
$(TEST_MODULE_1)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(TEST_MODULE_1)_Src))))

$(TEST_MODULE_1)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib \
	-I/usr/include
$(TEST_MODULE_1)_Linux_SHLIB_PATH = -target x86_64-linux-gnu -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux -I/usr/include \
	-L$(BUILD_ROOT_DIR)/lib
$(TEST_MODULE_1)_SHLIB_PATH = $($(TEST_MODULE_1)_$(OS)_SHLIB_PATH)

$(TEST_MODULE_1)_Darwin_LFLAGS = $($(TEST_MODULE_1)_SHLIB_PATH) -arch x86_64 \
	-isysroot $(SDK) \
	-Xlinker -rpath -Xlinker -map -Xlinker -no_deduplicate \
	-Xlinker -rpath -Xlinker $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/$(TEST_MODULE_1).swiftmodule \
	-framework IOIni
$(TEST_MODULE_1)_Linux_LFLAGS = $($(TEST_MODULE_1)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm \
	-lFoundation -lIOIni \
	-Xlinker -rpath \
	-Xlinker -no_deduplicate \
	-stdlib=libc++ -flto -fuse-ld=gold \
	-shared
$(TEST_MODULE_1)_LFLAGS = $($(TEST_MODULE_1)_$(OS)_LFLAGS)

$(TEST_MODULE_1)-install:
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).bin $(BUILD_ROOT_DIR)/bin/$(MODULE_4_REAL_NAME)
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftmodule $(BUILD_ROOT_DIR)/lib/x86_64
	@cp $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftdoc $(BUILD_ROOT_DIR)/lib/x86_64
	@chmod +x $(BUILD_ROOT_DIR)/bin/$(MODULE_4_REAL_NAME)

$(TEST_MODULE_1)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/$(MODULE_4_NAME)

$(TEST_MODULE_1): $(MODULE_4_NAME)-modulecache $(MODULE_4_NAME).bin $(MODULE_4_NAME)-install

$(TEST_MODULE_1).bin: $($(MODULE_4_NAME)_Obj) $(MODULE_4_NAME).swiftmodule
	clang $($(MODULE_4_NAME)_Obj) $($(MODULE_4_NAME)_LFLAGS) -o $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).bin

$(TEST_MODULE_1).swiftmodule:
	$(SWIFTC) -frontend $($(MODULE_4_NAME)_SWIFTC_FLAGS) -emit-module $($(MODULE_4_NAME)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/$(MODULE_4_NAME).swiftmodule

$(TEST_MODULE_1)-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/*.o $(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/*.so \
	$(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/*.swiftmodule $(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/*.d $(MODULE_CACHE_PATH)/$(TEST_MODULE_1) \
	$(BUILD_ROOT_DIR)/tests/$(TEST_MODULE_1)* \
	$(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/$(MODULE_4_NAME).bin
	
$(TEST_MODULE_1)/%.o : $(TEST_MODULE_1)/%.swift
	$(SWIFTC) -frontend -c $(subst $<,,$($(TEST_MODULE_1)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(TEST_MODULE_1)_SWIFTC_FLAGS) \
	-o $@
	
