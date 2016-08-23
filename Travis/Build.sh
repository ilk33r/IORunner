#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	if [[ $BUILD_FOR == 'trusty_swift3' ]]; then

		export PATH="$PWD/swift/${SWIFT_VERSION}-ubuntu14.04/usr/bin:$PATH"
		which swiftc
		make dist

	elif [[ $BUILD_FOR == 'wily_swift3' ]]; then

		export PATH="$PWD/swift/${SWIFT_VERSION}-ubuntu15.10/usr/bin:$PATH"
		which swiftc
		make dist

	fi
else
	which swiftc
	make dist
fi
