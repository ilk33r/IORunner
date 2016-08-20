#!/bin/bash

#  BeforeInstall.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	mkdir swift

	curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1404/swift-3.0-PREVIEW-4/swift-3.0-PREVIEW-4-ubuntu14.04.tar.gz -s | tar xz -C swift &> /dev/null

	env PATH=$(pwd)/swift/$SWIFT_VERSION-ubuntu14.04/usr/bin:$PATH
fi
