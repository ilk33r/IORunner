#!/bin/bash

#  CreateExtensionConfigs.sh
#  IORunner
#
#  Created by ilker özcan on 11/08/16.
#

# DIRECTORY_LIST=$(./Extensions/*)
# IFS=', ' read -r -a EXTENSIONS_ARR <<< "$DIRECTORY_LIST";
# FILESCOUNT=${#DIRECTORY_LIST[@]}
ALL_CONFIG_FILES_PATH=""

IDX=0
for CURRENT_EXT_DIR in ./Extensions/*; do

	if [ -d "${CURRENT_EXT_DIR}" ]; then

		echo "Reading ${CURRENT_EXT_DIR} extension config file"
		if [ $IDX -eq 0 ]; then
			ALL_CONFIG_FILES_PATH="${CURRENT_EXT_DIR}/Config.ini"
		else
			ALL_CONFIG_FILES_PATH="${ALL_CONFIG_FILES_PATH} ${CURRENT_EXT_DIR}/Config.ini"
		fi

	(( IDX++ ))
fi

done


#for ((i=0; i<$FILESCOUNT; i++)); do

#	CURRENT_EXT_DIR="./Extensions/${DIRECTORY_LIST[$i]}"
#	if [ -d "${CURRENT_EXT_DIR}" ]; then

#		echo "Reading ${CURRENT_EXT_DIR} extension config file"
#		if [ $IDX -eq 0 ]; then
#			ALL_CONFIG_FILES_PATH="${CURRENT_EXT_DIR}/Config.ini"
#		else
#			ALL_CONFIG_FILES_PATH="${ALL_CONFIG_FILES_PATH} ${CURRENT_EXT_DIR}/Config.ini"
#		fi
#
#		(( IDX++ ))
#	fi

#done

rm -f ./Build/IORunnerInstallConfig
touch ./Build/IORunnerInstallConfig

ALL_CONFIG_FILES_PATH_CHAR_COUNT=${#ALL_CONFIG_FILES_PATH}

if [ $ALL_CONFIG_FILES_PATH_CHAR_COUNT -gt 5 ]; then
	cat ${ALL_CONFIG_FILES_PATH} >> ./Build/IORunnerInstallConfig
fi




