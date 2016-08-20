#!/bin/sh

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#


if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	env PATH=$(pwd)/swift/$SWIFT_VERSION-ubuntu14.04/usr/bin:$PATH make dist
else
	make dist
fi
