# Makefile for IORunnerTest

SOURCE_ROOT_DIR=$(shell pwd)
BUILD_ROOT_DIR=$(SOURCE_ROOT_DIR)/../Build
MODULE_CACHE_PATH=$(BUILD_ROOT_DIR)/../ModuleCache

OS = $(shell uname)
SWIFTC = swift
CC = clang
CXX = clang
MODULE_NAME = IORunnerTest
DEBUG = -g -Onone

XCODE = $(shell xcode-select -p)
SDK = $(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk

LSB_OS = $(shell lsb_release -si)
LSB_VER = $(shell lsb_release -sr)

Darwin_SWIFTC_FLAGS= -sdk $(SDK) -D $(OS)_$(subst .,_,$(shell uname -r)) -D DEBUG
Linux_SWIFTC_FLAGS = -I linked/LinuxBridge
Linux_EXTRA_FLAGS = -D $(LSB_OS)_$(subst .,_,$(LSB_VER)) -DDEBUG

CFLAGS = -fPIC
CPPFLAGS = -fPIC

TEST_MODULE_1=iniTest

all: $(IORunnerTest)

modulecache:
	@mkdir -p $(BUILD_ROOT_DIR)/tests
	
include $(SOURCE_ROOT_DIR)/$(TEST_MODULE_1)/Makefile
	
$(IORunnerTest): modulecache $(TEST_MODULE_1)
	
$(MODULE_NAME)-clean:
	@rm -rf $(BUILD_ROOT_DIR)/tests

clean: $(TEST_MODULE_1)-clean $(MODULE_NAME)-clean

.PHONY: all clean


	