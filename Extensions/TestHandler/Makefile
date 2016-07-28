# Makefile for TestHandler

$(ExtensionName)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/$(ExtensionName) -module-name $(ExtensionName) $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

$(ExtensionName)_Src = Extensions/$(ExtensionName)/$(ExtensionName).swift
$(ExtensionName)_Obj = $(addsuffix .o, $(basename $($(ExtensionName)_Src)))
$(ExtensionName)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(ExtensionName)_Src))))

$(ExtensionName)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib
$(ExtensionName)_Linux_SHLIB_PATH = -target x86_64-linux-gnu -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux -I/usr/include \
	-L$(BUILD_ROOT_DIR)/lib
$(ExtensionName)_SHLIB_PATH = $($(ExtensionName)_$(OS)_SHLIB_PATH)

$(ExtensionName)_Darwin_LFLAGS = $($(ExtensionName)_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/lib$(ExtensionName).dylib \
	-stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).swiftmodule -single_module \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)

$(ExtensionName)_Linux_LFLAGS = $($(ExtensionName)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm \
	-lFoundation -l$(MODULE_1_NAME) -l$(MODULE_2_NAME) \
	-Xlinker -rpath \
	-Xlinker -no_deduplicate \
	-stdlib=libc++ -flto -fuse-ld=gold \
	-shared

$(ExtensionName)_LFLAGS = $($(ExtensionName)_$(OS)_LFLAGS)
	
