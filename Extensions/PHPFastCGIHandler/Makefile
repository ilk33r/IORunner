# Makefile for PHPFastCGIHandler

PHPFastCGIHandler_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/PHPFastCGIHandler -module-name PHPFastCGIHandler $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

PHPFastCGIHandler_Src = Extensions/PHPFastCGIHandler/PHPFastCGIHandler.swift
PHPFastCGIHandler_Obj = $(addsuffix .o, $(basename $(PHPFastCGIHandler_Src)))
PHPFastCGIHandler_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $(PHPFastCGIHandler_Src))))

PHPFastCGIHandler_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs) \
	-I/usr/include
PHPFastCGIHandler_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
	-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
	-L$(BUILD_ROOT_DIR)/lib -I/usr/include
PHPFastCGIHandler_SHLIB_PATH = $(PHPFastCGIHandler_$(OS)_SHLIB_PATH)

PHPFastCGIHandler_Darwin_LFLAGS = $(PHPFastCGIHandler_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/libPHPFastCGIHandler.dylib \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/Extensions/PHPFastCGIHandler/PHPFastCGIHandler.swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)
PHPFastCGIHandler_Linux_LFLAGS = $(PHPFastCGIHandler_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \
	-l$(MODULE_1_NAME) -l$(MODULE_2_NAME) -shared -flto -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	-Xlinker -rpath -Xlinker '/usr/lib64' \
	-Xlinker -rpath -Xlinker '/usr/lib' \
	-Xlinker -rpath -Xlinker '/usr/local/lib64' \
	-Xlinker -rpath -Xlinker '/usr/local/lib' \
	$(SWIFT_libs)/x86_64/swift_end.o
PHPFastCGIHandler_LFLAGS = $(PHPFastCGIHandler_$(OS)_LFLAGS)

ext-PHPFastCGIHandler-make: ext-PHPFastCGIHandler-modulecache ext-PHPFastCGIHandler.so ext-PHPFastCGIHandler-install

ext-PHPFastCGIHandler-objects: $(PHPFastCGIHandler_Obj)


