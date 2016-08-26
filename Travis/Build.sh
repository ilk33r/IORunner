#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_IMAGE == 'Docker' ]]; then

	docker run ilk3r/iorunner:trusty /bin/bash -c "cd /root/ilk33r/IORunner/; git pull; make dist; ./Travis/Deploy.sh"
else
	make dist
fi
