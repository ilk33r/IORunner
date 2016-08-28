#!/bin/bash

#  Deploy.sh
#  IORunner
#
#  Created by ilker özcan on 23/08/16.
#

RELEASE_NAME=""

if [[ -f ./Build/IORunnerInstaller ]]; then

	if [[ $TRAVIS_TAG == '' ]]; then

		if [[ $TRAVIS_IMAGE == 'Docker' ]]; then

			RELEASE_NAME="IORunnerInstaller_${APP_VERSION}_${DOCKER_OS_RELEASE}_swift_3"
		else
			RELEASE_NAME="IORunnerInstaller_${APP_VERSION}_Darwin_swift_${SWIFT_VERSION}"
		fi

		echo "Release Name = $RELEASE_NAME"
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

	echo "" >&1
	echo "Deployment success!" >&1
	exit 0
else
	echo "Deployment failed!" >&2
	exit 1
fi
