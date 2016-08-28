#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TEST_BRANCH == $TRAVIS_BRANCH ]]; then

	if [[ $TRAVIS_IMAGE == 'Docker' ]]; then

		docker run -e "OS_RELEASE=${DOCKER_OS_RELEASE}" -e "PATH=/usr/swift/swift-3.0-PREVIEW-6-ubuntu14.04/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" -e "TRAVIS_COMMIT=${TRAVIS_COMMIT}" -e "TRAVIS_IMAGE=${TRAVIS_IMAGE}" ilk3r/iorunner:${DOCKER_IMAGE} /bin/bash -c "cd /root/ilk33r/IORunner/; git pull;  make dist; make deploy;"

	else
		make dist
		make deploy;
	fi

else
	exit 0
fi
