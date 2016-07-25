# Makefile for IORunner

SOURCE_ROOT_DIR=$(shell pwd)
BUILD_ROOT_DIR=$(SOURCE_ROOT_DIR)/Build
MODULE_CACHE_PATH=$(BUILD_ROOT_DIR)/ModuleCache

OS = $(shell uname)
SWIFTC = swift
CC = clang
CXX = clang
MODULE_NAME = IORunner
DEBUG = -gnone -O -whole-module-optimization

XCODE=$(shell xcode-select -p)
SDK=$(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk

LSB_OS = $(shell lsb_release -si)
LSB_VER = $(shell lsb_release -sr)

Darwin_SWIFTC_FLAGS = -sdk $(SDK)
Linux_SWIFTC_FLAGS = -I linked/LinuxBridge
Linux_EXTRA_FLAGS = -D $(LSB_OS)_$(subst .,_,$(LSB_VER))

CFLAGS = -fPIC
CPPFLAGS = -fPIC

MODULE_1_NAME=IOIni
MODULE_2_NAME=IORunnerExtension
MODULE_3_NAME=IOGUI
MODULE_4_NAME=IORunnerBin

all: $(MODULE_NAME)

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
	
.PHONY: all clean dist-clean extensions dist


	