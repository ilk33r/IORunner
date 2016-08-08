# Makefile for TestHandler

$(ExtensionName)_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/$(ExtensionName) -module-name $(ExtensionName) $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

$(ExtensionName)_Src = Extensions/$(ExtensionName)/$(ExtensionName).swift
$(ExtensionName)_Obj = $(addsuffix .o, $(basename $($(ExtensionName)_Src)))
$(ExtensionName)_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $($(ExtensionName)_Src))))

$(ExtensionName)_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs) \
	-I/usr/include
$(ExtensionName)_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
	-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
	-L$(BUILD_ROOT_DIR)/lib -I/usr/include
$(ExtensionName)_SHLIB_PATH = $($(ExtensionName)_$(OS)_SHLIB_PATH)

$(ExtensionName)_Darwin_LFLAGS = $($(ExtensionName)_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/lib$(ExtensionName).dylib \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)

$(ExtensionName)_Linux_LFLAGS = $($(ExtensionName)_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lm -lpthread -licui18n -licuuc -lFoundation -lbsd \
	-l$(MODULE_1_NAME) -l$(MODULE_2_NAME) -shared -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '${ORIGIN}/../lib/x86_64/$(MODULE_3_NAME).swiftmodule' \
	-Xlinker -rpath -Xlinker '${ORIGIN}/../lib' \
	$(SWIFT_libs)/x86_64/swift_end.o

$(ExtensionName)_LFLAGS = $($(ExtensionName)_$(OS)_LFLAGS)
	
