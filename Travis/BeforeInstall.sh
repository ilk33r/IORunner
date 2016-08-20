#!/bin/bash

#  BeforeInstall.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

	mkdir swift

	case "${SWIFT_BUILD}" in

		Ubuntu14)
			curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1404/swift-3.0-PREVIEW-4/swift-3.0-PREVIEW-4-ubuntu14.04.tar.gz -s | tar xz -C swift &> /dev/null

			export PATH=$(pwd)/swift/$SWIFT_VERSION-ubuntu14.04/usr/bin:$PATH
		;;
		Ubuntu15)
			curl https://swift.org/builds/swift-3.0-preview-4/ubuntu1510/swift-3.0-PREVIEW-4/swift-3.0-PREVIEW-4-ubuntu15.10.tar.gz -s | tar xz -C swift &> /dev/null

			export PATH=$(pwd)/swift/$SWIFT_VERSION-ubuntu15.10/usr/bin:$PATH
		;;
	esac
fi
