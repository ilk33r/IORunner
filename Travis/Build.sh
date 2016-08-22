#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	export PATH="$PWD/swift/$SWIFT_VERSION-ubuntu14.04/usr/bin:$PATH"
	which swiftc
	make dist
else
	make dist
fi
