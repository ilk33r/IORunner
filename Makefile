# Makefile for IORunner

BUILD := release
SOURCE_ROOT_DIR=$(shell pwd)
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
SDK = $(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk

LSB_OS = $(shell lsb_release -si)
LSB_VER = $(shell lsb_release -sr)

Darwin_SWIFTC_FLAGS.release = -sdk $(SDK) -D $(OS)_$(subst .,_,$(shell uname -r))
Darwin_SWIFTC_FLAGS.debug= -sdk $(SDK) -D $(OS)_$(subst .,_,$(shell uname -r)) -D DEBUG
Darwin_SWIFTC_FLAGS := $(Darwin_SWIFTC_FLAGS.$(BUILD))
Linux_SWIFTC_FLAGS = -I linked/LinuxBridge
Linux_EXTRA_FLAGS.release = -D $(LSB_OS)_$(subst .,_,$(LSB_VER))
Linux_EXTRA_FLAGS.debug = -D $(LSB_OS)_$(subst .,_,$(LSB_VER)) -D DEBUG
Linux_EXTRA_FLAGS := $(Linux_EXTRA_FLAGS.$(BUILD))

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
	
include $(SOURCE_ROOT_DIR)/$(MODULE_1_NAME)/Makefile $(SOURCE_ROOT_DIR)/$(MODULE_2_NAME)/Makefile $(SOURCE_ROOT_DIR)/$(MODULE_3_NAME)/Makefile \
	$(SOURCE_ROOT_DIR)/$(MODULE_4_NAME)/Makefile $(SOURCE_ROOT_DIR)/Extensions/Makefile \
	$(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/Makefile
	
$(MODULE_NAME): modulecache $(MODULE_1_NAME) $(MODULE_2_NAME) $(MODULE_3_NAME) $(MODULE_4_NAME)
	
extensions: AllExtensions

$(MODULE_NAME)-clean:
	@rm -rf $(BUILD_ROOT_DIR)/bin
	@rm -rf $(BUILD_ROOT_DIR)/frameworks
	@rm -rf $(BUILD_ROOT_DIR)/lib
	@rm -rf $(BUILD_ROOT_DIR)/ModuleCache
	@rm -rf $(BUILD_ROOT_DIR)/extensions

clean: $(MODULE_1_NAME)-clean $(MODULE_2_NAME)-clean $(MODULE_3_NAME)-clean $(MODULE_4_NAME)-clean AllExtensions-Clean $(MODULE_NAME)Installer-clean

dist-clean: clean $(MODULE_NAME)-clean
	
dist-create-zip:
	@zip -r -D -y $(BUILD_ROOT_DIR)/$(MODULE_NAME)-$(OS)-x86_64.zip Build/bin/ Build/extensions/ Build/lib/ Build/frameworks/
	@mv $(BUILD_ROOT_DIR)/$(MODULE_NAME)-$(OS)-x86_64.zip $(BUILD_ROOT_DIR)/$(MODULE_NAME)InstallData
	@xxd -i Build/$(MODULE_NAME)InstallData $(SOURCE_ROOT_DIR)/$(MODULE_NAME)Installer/InstallDataEx.h 
	
dist: dist-create-zip $(MODULE_NAME)Installer
	
source-dist: dist-clean
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
	@mv $(BUILD_ROOT_DIR)/$(MODULE_NAME) $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src
	@find $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src -name ".*" -exec rm -rf {} \;
	@tar -cvzf $(BUILD_ROOT_DIR)/$(MODULE_NAME)-Source.tar.gz $(MODULE_NAME)-Src
	@rm -rf $(SOURCE_ROOT_DIR)/$(MODULE_NAME)-Src
	@rm $(SOURCE_ROOT_DIR)/Config.ini*
	@rm -rf $(BUILD_ROOT_DIR)/lldb-ext*
	
.PHONY: all extensions clean dist-clean dist source-dist debug


	