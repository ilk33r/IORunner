# Makefile for TestHandler

TestHandler_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/TestHandler -module-name TestHandler $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

TestHandler_Src = Extensions/TestHandler/TestHandler.swift
TestHandler_Obj = $(addsuffix .o, $(basename $(TestHandler_Src)))
TestHandler_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $(TestHandler_Src))))

TestHandler_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs) \
	-I/usr/include
TestHandler_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
	-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
	-L$(BUILD_ROOT_DIR)/lib -I/usr/include
TestHandler_SHLIB_PATH = $(TestHandler_$(OS)_SHLIB_PATH)

TestHandler_Darwin_LFLAGS = $(TestHandler_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/libTestHandler.dylib \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/Extensions/TestHandler/TestHandler.swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)
TestHandler_Linux_LFLAGS = $(TestHandler_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \
	-l$(MODULE_1_NAME) -l$(MODULE_2_NAME) -shared -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	$(SWIFT_libs)/x86_64/swift_end.o
TestHandler_LFLAGS = $(TestHandler_$(OS)_LFLAGS)

ext-TestHandler-make: ext-TestHandler-modulecache ext-TestHandler.so ext-TestHandler-install

ext-TestHandler-objects: $(TestHandler_Obj)
	
