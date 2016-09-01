# Makefile for BouncyHandler

BouncyHandler_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/BouncyHandler -module-name BouncyHandler $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

BouncyHandler_Src = Extensions/BouncyHandler/BouncyHandler.swift
BouncyHandler_Obj = $(addsuffix .o, $(basename $(BouncyHandler_Src)))
BouncyHandler_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $(BouncyHandler_Src))))

BouncyHandler_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs) \
	-I/usr/include
BouncyHandler_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
	-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
	-L$(BUILD_ROOT_DIR)/lib -I/usr/include
BouncyHandler_SHLIB_PATH = $(BouncyHandler_$(OS)_SHLIB_PATH)

BouncyHandler_Darwin_LFLAGS = $(BouncyHandler_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/libBouncyHandler.dylib \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/Extensions/BouncyHandler/BouncyHandler.swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)
BouncyHandler_Linux_LFLAGS = $(BouncyHandler_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \
	-l$(MODULE_1_NAME) -l$(MODULE_2_NAME) -shared -flto -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	-Xlinker -rpath -Xlinker '/usr/lib64' \
	-Xlinker -rpath -Xlinker '/usr/lib' \
	-Xlinker -rpath -Xlinker '/usr/local/lib64' \
	-Xlinker -rpath -Xlinker '/usr/local/lib' \
	$(SWIFT_libs)/x86_64/swift_end.o
BouncyHandler_LFLAGS = $(BouncyHandler_$(OS)_LFLAGS)

ext-BouncyHandler-make: ext-BouncyHandler-modulecache ext-BouncyHandler.so ext-BouncyHandler-install

ext-BouncyHandler-objects: $(BouncyHandler_Obj)


