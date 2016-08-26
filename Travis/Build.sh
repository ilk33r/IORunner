#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_IMAGE == 'Docker' ]]; then

	docker run -e "OS_RELEASE=${DOCKER_OS_RELEASE}" -e "PATH=/usr/swift/swift-3.0-PREVIEW-4-ubuntu14.04/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ilk3r/iorunner:${DOCKER_IMAGE} /bin/bash -c "cd /root/ilk33r/IORunner/; git pull;  make dist; ./Travis/Deploy.sh"

else
	make dist
fi
