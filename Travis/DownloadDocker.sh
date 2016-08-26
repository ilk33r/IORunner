#!/bin/bash

#  run_docker.sh
#  IORunner
#
#  Created by ilker özcan on 26/08/16.
#

if [[ ! -d docker ]]; then
	mkdir docker
fi

if [[ -f docker/iorunner_${DOCKER_IMAGE}.tar ]]; then
	docker import docker/iorunner_${DOCKER_IMAGE}.tar ilk3r/iorunner:${DOCKER_IMAGE}
else
	docker pull ilk3r/iorunner:${DOCKER_IMAGE}
	docker run --name iorunner_${DOCKER_IMAGE} ilk3r/iorunner:${DOCKER_IMAGE} /bin/true
	docker export -o docker/iorunner_${DOCKER_IMAGE}.tar iorunner_${DOCKER_IMAGE}
fi
