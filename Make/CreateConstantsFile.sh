#!/bin/bash

#  CreateConstantsFile.sh
#  IORunner
#
#  Created by ilker özcan on 23/08/16.
#

CREATE_CONST_FILE() {

	# 1 PATH
	# 2 APP_NAME
	# 3 APP_VERSION
	# 4 APP_VERSION_INT
	# 5 APP_CREDITS
	# 6 APP_PACKAGE_NAME
	# 7 CpuSleepMsec
	# 8 CpuSleepSec
	# 9 GuiRefreshRate
	echo "" > $1
	echo "//" >> $1
	echo "//  Constants.swift" >> $1
	echo "//  ${6}" >> $1
	echo "//" >> $1
	echo "//  Created by ilker özcan on 04/07/16." >> $1
	echo "//  Auto generated by Makefile" >> $1
	echo "//" >> $1
	echo "//" >> $1
	echo "" >> $1
	echo "public struct Constants {" >> $1
	echo "" >> $1
	echo "	public static let APP_NAME = \"${2}\"" >> $1
	echo "	public static let APP_VERSION = \"${3}\"" >> $1
	echo "	public static let APP_VERSION_INT = \"${4}\"" >> $1
	echo "	public static let APP_CREDITS = \"${5}\"" >> $1
	echo "	public static let APP_PACKAGE_NAME = \"${6}\"" >> $1
	echo "" >> $1
	echo "	public static let CpuSleepMsec = ${7}" >> $1
	echo "	public static let CpuSleepSec: UInt32 = ${8}" >> $1
	echo "	public static let GuiRefreshRate: UInt32 = ${9}" >> $1
	echo "" >> $1
	echo "}" >> $1
	echo "" >> $1
	echo "" >> $1

}

echo "Generating constants file"
CREATE_CONST_FILE "./IORunnerBin/Constants.swift" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
echo "[OK!]"



