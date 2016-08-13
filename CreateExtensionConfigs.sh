#!/bin/bash

#  CreateExtensionConfigs.sh
#  IORunner
#
#  Created by ilker özcan on 11/08/16.
#

DIRECTORY_LIST=$(ls -m ./Extensions/)

IFS=', ' read -r -a EXTENSIONS_ARR <<< "$DIRECTORY_LIST";
FILESCOUNT=${#EXTENSIONS_ARR[@]}
ALL_CONFIG_FILES_PATH=""

IDX=0

for ((i=0; i<$FILESCOUNT; i++)); do

	CURRENT_EXT_DIR="./Extensions/${EXTENSIONS_ARR[$i]}"
	if [ -d "${CURRENT_EXT_DIR}" ]; then

		if [ $IDX -eq 0 ]; then
			ALL_CONFIG_FILES_PATH="${CURRENT_EXT_DIR}/Config.ini"
		else
			ALL_CONFIG_FILES_PATH="${ALL_CONFIG_FILES_PATH} ${CURRENT_EXT_DIR}/Config.ini"
		fi

		(( IDX++ ))
	fi

done

rm -f ./Build/IORunnerInstallConfig
touch ./Build/IORunnerInstallConfig

ALL_CONFIG_FILES_PATH_CHAR_COUNT=${#ALL_CONFIG_FILES_PATH}

if [ $ALL_CONFIG_FILES_PATH_CHAR_COUNT -gt 5 ]; then
	cat ${ALL_CONFIG_FILES_PATH} >> ./Build/IORunnerInstallConfig
fi




