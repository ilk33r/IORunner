#!/bin/bash

#  CreateRelease.sh
#  IORunner
#
#  Created by ilker özcan on 23/08/16.
#

if [[ $TRAVIS_TAG != '' ]]; then

	API_JSON=$(printf '{"tag_name": "v${TRAVIS_TAG}","target_commitish": "master", "name": "v${TRAVIS_TAG}","body": "Release of version ${TRAVIS_TAG}", "draft": false, "prerelease": false}')
	curl --data "$API_JSON" https://api.github.com/repos/ilk33r/IORunner/releases?access_token=${GITHUB_TOKEN}

#	git tag -a 1.0.0 -m "Release of version 1.0.0"
#	git push --tags
fi
