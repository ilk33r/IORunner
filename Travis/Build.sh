#!/bin/bash

#  Build.sh
#  IORunner
#
#  Created by ilker özcan on 21/08/16.
#

if [[ $TRAVIS_IMAGE == 'Docker' ]]; then

	cd /root/ilk33r/IORunner/
	git pull
	make dist
else
	which swiftc
	make dist
fi
