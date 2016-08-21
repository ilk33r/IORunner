#!/bin/bash

#  BeforeInstall.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	mkdir swift

	curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1404/swift-3.0-PREVIEW-4/swift-3.0-PREVIEW-4-ubuntu14.04.tar.gz -s | tar xz -C swift &> /dev/null
	export PATH="$PWD/swift/$SWIFT_VERSION-ubuntu14.04/usr/bin:$PATH"

	sudo ln -sf /usr/lib/llvm-3.4/lib/LLVMgold.so /usr/lib/LLVMgold.so
	sudo echo /usr/lib/llvm-3.4/lib >> /etc/ld.so.conf
fi
