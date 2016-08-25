#!/bin/bash

#  Deploy.sh
#  IORunner
#
#  Created by ilker özcan on 23/08/16.
#

RELEASE_NAME=""

if [[ $TRAVIS_TAG != '' ]]; then

	if [[ $TRAVIS_OS_NAME == 'linux' ]]; then

		if [[ $BUILD_FOR == 'trusty_swift3' ]]; then

			RELEASE_NAME="IORunnerInstaller_${TRAVIS_TAG}_ubuntu_trusty_swift_3"

		elif [[ $BUILD_FOR == 'wily_swift3' ]]; then

			RELEASE_NAME="IORunnerInstaller_${TRAVIS_TAG}_ubuntu_wily_swift_3"

		fi
	else
		RELEASE_NAME="IORunnerInstaller_${TRAVIS_TAG}_Darwin_swift_2.2"
	fi

	cp ./Build/IORunnerInstaller ./Build/${RELEASE_NAME}
	zip ./Build/${RELEASE_NAME}.zip ./Build/${RELEASE_NAME}

curl \
-H "Accept: application/json" \
-H "Content-Type: application/zip" \
-H "X-IO-Travis-CommitID: ${TRAVIS_COMMIT}" \
-H "X-IO-Travis-FileName: ${RELEASE_NAME}.zip" \
--data-binary @./Build/${RELEASE_NAME}.zip \
"http://ilkerozcan.com.tr/iorunner/uploadbuild/"

fi
