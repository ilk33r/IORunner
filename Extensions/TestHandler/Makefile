# Makefile for TestHandler

TestHandler-SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/$(ExtensionName) -module-name $(ExtensionName) $($(OS)_SWIFTC_FLAGS) -enable-objc-interop \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

TestHandler-Src = Extensions/$(ExtensionName)/$(ExtensionName).swift
TestHandler-Obj = $(addsuffix .o, $(basename $($(ExtensionName)-Src)))
TestHandler-Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(ExtensionName)-Src))))

TestHandler-Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib
TestHandler-Linux_SHLIB_PATH = -L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux
TestHandler-SHLIB_PATH = $($(ExtensionName)-$(OS)_SHLIB_PATH)

TestHandler-Darwin_LFLAGS = $($(ExtensionName)-SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/lib$(ExtensionName).dylib \
	-stdlib=libc++ \
	-L$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
	-Xlinker -add_ast_path -Xlinker $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).swiftmodule -single_module \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)

TestHandler-Linux_LFLAGS = $($(ExtensionName)-SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm -lFoundation -lProcessCheckerExtension -lini -shared

TestHandler-LFLAGS = $($(ExtensionName)-$(OS)_LFLAGS)
	
