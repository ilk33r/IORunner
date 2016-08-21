# Makefile for IORunner

BUILD := release
SOURCE_ROOT_DIR=$(PWD)
BUILD_ROOT_DIR=$(SOURCE_ROOT_DIR)/Build
MODULE_CACHE_PATH=$(BUILD_ROOT_DIR)/ModuleCache

OS = $(shell uname)
SWIFT = swift
Darwin_CLANG = clang++
Linux_CLANG = clang++ $(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux/x86_64/swift_begin.o
CLANG = $($(OS)_CLANG)
MODULE_NAME = IORunner
DEBUG.release = -gnone -O -whole-module-optimization
DEBUG.debug = -g -Onone
DEBUG := $(DEBUG.$(BUILD))

XCODE = $(shell xcode-select -p)
SDK = $(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk

LSB_OS = $(shell lsb_release -si)
LSB_VER = $(shell lsb_release -sr)

Darwin_SWIFTC_FLAGS.release = -sdk $(SDK) -D $(OS)_$(subst .,_,$(shell uname -r)) -Xcc -D$(OS)=1
Darwin_SWIFTC_FLAGS.debug= -sdk $(SDK) -D $(OS)_$(subst .,_,$(shell uname -r)) -D DEBUG -Xcc -D$(OS)=1
Darwin_SWIFTC_FLAGS := $(Darwin_SWIFTC_FLAGS.$(BUILD))
Linux_SWIFTC_FLAGS = -I linked/LinuxBridge
Linux_EXTRA_FLAGS.release = -D $(LSB_OS)_$(subst .,_,$(LSB_VER))
Linux_EXTRA_FLAGS.debug = -D $(LSB_OS)_$(subst .,_,$(LSB_VER)) -D DEBUG
Linux_EXTRA_FLAGS := $(Linux_EXTRA_FLAGS.$(BUILD)) -D $(OS) -Xcc -D$(OS)=1

SWIFT_Darwin_libs = $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx
SWIFT_Linux_libs = $(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift/linux
SWIFT_libs = $(SWIFT_$(OS)_libs)

SWIFT_Static_Darwin_libs = $(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift_static/macosx
SWIFT_Static_Linux_libs = $(shell dirname $(shell dirname $(shell which swiftc)))/lib/swift_static/linux
SWIFT_Static_libs = $(SWIFT_Static_$(OS)_libs)

Darwin_Dependencies_Command=otool -L /usr/local/$(MODULE_NAME)/bin/$(MODULE_NAME)
Linux_Dependencies_Command=readelf -d /usr/local/$(MODULE_NAME)/bin/$(MODULE_NAME)
# ldd /usr/local/$(MODULE_NAME)/bin/$(MODULE_NAME)
Dependencies_Command=$($(OS)_Dependencies_Command)

MODULE_1_NAME=IOIni
MODULE_2_NAME=IORunnerExtension
MODULE_3_NAME=IOGUI
MODULE_4_NAME=IORunnerBin

all: $(MODULE_NAME)

prepare-debug: 
	@rm -f $(SOURCE_ROOT_DIR)/Config.ini*
	@rm -rf $(BUILD_ROOT_DIR)/lldb-ext*
	@touch $(SOURCE_ROOT_DIR)/Config.ini
	@echo "[Daemonize]" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "Daemonize=1" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "Pid=$(BUILD_ROOT_DIR)/lldb.pid" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "[Logging]" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "LogLevel=2" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "LogFile==$(BUILD_ROOT_DIR)/lldb.log" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "MaxLogSize==100000000" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "[Extensions]" >> $(SOURCE_ROOT_DIR)/Config.ini
	@echo "ExtensionsDir=$(BUILD_ROOT_DIR)/lldb-ext" >> $(SOURCE_ROOT_DIR)/Config.ini

install-debug:
	@mkdir -p $(BUILD_ROOT_DIR)/lldb-ext
	@mkdir -p $(BUILD_ROOT_DIR)/lldb-ext/available
	@mkdir -p $(BUILD_ROOT_DIR)/lldb-ext/enabled
	@cp -r $(BUILD_ROOT_DIR)/extensions/*.dylib $(BUILD_ROOT_DIR)/lldb-ext/available
	@lldb $(BUILD_ROOT_DIR)/bin/$(MODULE_NAME) -- -c $(SOURCE_ROOT_DIR)/Config.ini

debug: prepare-debug $(MODULE_NAME) extensions install-debug

modulecache:
	@mkdir -p $(BUILD_ROOT_DIR)
	@mkdir -p $(BUILD_ROOT_DIR)/lib
	@mkdir -p $(BUILD_ROOT_DIR)/lib/x86_64
	@mkdir -p $(BUILD_ROOT_DIR)/frameworks
	@mkdir -p $(BUILD_ROOT_DIR)/bin
	@mkdir -p $(BUILD_ROOT_DIR)/extensions
	@mkdir -p $(MODULE_CACHE_PATH)
	@mkdir -p $(MODULE_CACHE_PATH)/Extensions
	
Copy_Darwin_dependencies:
	@cp -r $(SWIFT_libs)/libswiftCore.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftCoreGraphics.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftDarwin.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftDispatch.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftFoundation.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftIOKit.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftObjectiveC.dylib $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftXPC.dylib $(BUILD_ROOT_DIR)/lib 2>/dev/null || :
	
Copy_Linux_dependencies:
	@cp -r $(SWIFT_libs)/libswiftCore.so $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libswiftGlibc.so $(BUILD_ROOT_DIR)/lib
	@cp -r $(SWIFT_libs)/libFoundation.so $(BUILD_ROOT_DIR)/lib
	@cp -Hr /usr/lib/x86_64-linux-gnu/libicui18n.so $(BUILD_ROOT_DIR)/lib/libicui18n.so.55
	@cp -Hr /usr/lib/x86_64-linux-gnu/libicuuc.so $(BUILD_ROOT_DIR)/lib/libicuuc.so.55
	@cp -Hr /usr/lib/x86_64-linux-gnu/libicudata.so $(BUILD_ROOT_DIR)/lib/libicudata.so.55
	
include $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/Makefile $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/Makefile $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/Makefile \
	$(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/Makefile $(SOURCE_ROOT_DIR)/Extensions/Makefile \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/Makefile
	
$(MODULE_NAME): modulecache Copy_$(OS)_dependencies $(MODULE_1_NAME) $(MODULE_2_NAME) $(MODULE_3_NAME) $(MODULE_4_NAME)
	
extensions: AllExtensions

$(MODULE_NAME)-clean:
	@rm -rf $(BUILD_ROOT_DIR)/bin
	@rm -rf $(BUILD_ROOT_DIR)/frameworks
	@rm -rf $(BUILD_ROOT_DIR)/lib
	@rm -rf $(BUILD_ROOT_DIR)/ModuleCache
	@rm -rf $(BUILD_ROOT_DIR)/extensions

clean: $(MODULE_1_NAME)-clean $(MODULE_2_NAME)-clean $(MODULE_3_NAME)-clean $(MODULE_4_NAME)-clean AllExtensions-Clean

dist-clean: clean $(MODULE_NAME)-clean $(MODULE_NAME)Installer-clean
	@rm -rf $(BUILD_ROOT_DIR)
	
dist-create-zip:
	$(eval ZIP_FILE_EXISTS := $(shell [ -e $(BUILD_ROOT_DIR)/$(MODULE_NAME)InstallData ] && echo 1 || echo 0 ))
	@if [ $(ZIP_FILE_EXISTS) = 0 ]; then\
		eval zip -r -D -y $(BUILD_ROOT_DIR)/$(MODULE_NAME)-$(OS)-x86_64.zip Build/bin/ Build/extensions/ Build/lib/ Build/frameworks/; \
		eval mv $(BUILD_ROOT_DIR)/$(MODULE_NAME)-$(OS)-x86_64.zip $(BUILD_ROOT_DIR)/$(MODULE_NAME)InstallData; \
	fi
	$(eval CONFIG_FILE_EXISTS := $(shell [ -e Build/$(MODULE_NAME)InstallConfig ] && echo 1 || echo 0 ))
	@if [ $(CONFIG_FILE_EXISTS) = 0 ]; then\
		eval $(SOURCE_ROOT_DIR)/CreateExtensionConfigs.sh; \
	fi
	
dist: $(MODULE_NAME) extensions dist-create-zip $(MODULE_NAME)Installer
	
source-dist: dist-clean
	@mkdir -p $(BUILD_ROOT_DIR)
	@mkdir -p $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME) $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME) $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME) $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_4_NAME) $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/Extensions $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp $(SOURCE_ROOT_DIR)/Makefile $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp $(SOURCE_ROOT_DIR)/LICENSE $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/$(MODULE_NAME).xcodeproj $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/CreateExtension.sh $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@cp -r $(SOURCE_ROOT_DIR)/CreateExtensionConfigs.sh $(BUILD_ROOT_DIR)/$(MODULE_NAME)
	@mv $(BUILD_ROOT_DIR)/$(MODULE_NAME) $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src
	@find $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src -name ".*" -exec rm -rf {} \;
	@tar -cvzf $(BUILD_ROOT_DIR)/$(MODULE_NAME)-Source.tar.gz $(MODULE_NAME)-Src
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src
	@rm -f $(SOURCE_ROOT_DIR)/Config.ini*
	@rm -rf $(BUILD_ROOT_DIR)/lldb-ext*
	
.PHONY: all extensions clean dist-clean dist source-dist debug


	
