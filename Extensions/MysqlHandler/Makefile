# Makefile for MysqlHandler

MysqlHandler_SWIFTC_FLAGS = $(DEBUG) $($(OS)_EXTRA_FLAGS) \
	-module-cache-path $(MODULE_CACHE_PATH)/Extensions/MysqlHandler -module-name MysqlHandler $($(OS)_SWIFTC_FLAGS) \
	-I $(BUILD_ROOT_DIR)/lib -I $(BUILD_ROOT_DIR)/frameworks -F $(BUILD_ROOT_DIR)/frameworks

MysqlHandler_Src = Extensions/MysqlHandler/MysqlHandler.swift
MysqlHandler_Obj = $(addsuffix .o, $(basename $(MysqlHandler_Src)))
MysqlHandler_Modules = $(addprefix $(MODULE_CACHE_PATH)/, $(addsuffix .swiftmodule, $(basename $(MysqlHandler_Src))))

MysqlHandler_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I$(BUILD_ROOT_DIR)/lib -I$(BUILD_ROOT_DIR)/frameworks \
	-F$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/frameworks -L$(BUILD_ROOT_DIR)/lib -L$(SWIFT_libs) \
	-I/usr/include
MysqlHandler_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L$(SWIFT_libs) \
	-L$(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux \
	-L$(BUILD_ROOT_DIR)/lib -I/usr/include
MysqlHandler_SHLIB_PATH = $(MysqlHandler_$(OS)_SHLIB_PATH)

MysqlHandler_Darwin_LFLAGS = $(MysqlHandler_SHLIB_PATH) -arch x86_64 -dynamiclib \
	-isysroot $(SDK) \
	-install_name $(BUILD_ROOT_DIR)/extensions/libMysqlHandler.dylib \
	-Xlinker -add_ast_path \
	-stdlib=libc++ \
	-Xlinker $(SOURCE_ROOT_DIR)/Extensions/MysqlHandler/MysqlHandler.swiftmodule -single_module \
	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \
	-Xlinker -rpath -Xlinker @loader_path/Frameworks \
	-Xlinker -rpath -Xlinker @executable_path/../lib \
	-Xlinker -rpath -Xlinker @executable_path/../frameworks \
	-compatibility_version 1 -current_version 1 \
	-framework Foundation -framework $(MODULE_2_NAME) -framework $(MODULE_1_NAME)
MysqlHandler_Linux_LFLAGS = $(MysqlHandler_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \
	-l$(MODULE_1_NAME) -l$(MODULE_2_NAME) -shared -flto -fuse-ld=gold \
	-Xlinker -export-dynamic \
	-Xlinker --exclude-libs -Xlinker ALL \
	-Xlinker -rpath -Xlinker '$$ORIGIN/../lib' \
	$(SWIFT_libs)/x86_64/swift_end.o
MysqlHandler_LFLAGS = $(MysqlHandler_$(OS)_LFLAGS)

ext-MysqlHandler-make: ext-MysqlHandler-modulecache ext-MysqlHandler.so ext-MysqlHandler-install

ext-MysqlHandler-objects: $(MysqlHandler_Obj)


