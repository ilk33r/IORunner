#!/bin/bash

#  BeforeInstall.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

echo $SWIFT_VERSION

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	mkdir swift

	if [[ $BUILD_FOR == 'trusty_swift3' ]]; then

		curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1404/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu14.04.tar.gz -s | tar xz -C swift &> /dev/null

	elif [[ $BUILD_FOR == 'wily_swift3' ]]; then

		curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1510/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu15.10.tar.gz -s | tar xz -C swift &> /dev/null

	fi

	CLANG_PATH=$(which clang)
	CLANG_DIR=$(dirname $CLANG_PATH)

	sudo ln -sf /usr/lib/llvm-3.4/lib/LLVMgold.so $CLANG_DIR/../lib/LLVMgold.so

	sudo apt-get -qq update
	sudo apt-get install -y libbsd0
	sudo apt-get install -y libbsd-dev
fi
