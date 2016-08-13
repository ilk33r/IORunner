#!/bin/bash

#  CreateExtension.sh
#  IORunner
#
#  Created by ilker özcan on 10/08/16.
#

CREATE_EXT_SKELL_FILE() {

	echo "//" >> $1
	echo "//  ${2}" >> $1
	echo "//  IORunner/Extensions/${3}" >> $1
	echo "//" >> $1
	echo "//  Created by ilker özcan on 10/08/16." >> $1
	echo "//" >> $1
	echo "//" >> $1
	echo "" >> $1
	echo "import Foundation" >> $1
	echo "import IOIni" >> $1
	echo "import IORunnerExtension" >> $1
	echo "" >> $1
	echo "public class ${3}: AppHandlers {" >> $1
	echo "" >> $1
	echo "	public required init(logger: Logger, moduleConfig: Section?) {" >> $1
	echo "" >> $1
	echo "		super.init(logger: logger, moduleConfig: moduleConfig)" >> $1
	echo "	}" >> $1
	echo "" >> $1
	echo "	public override func forStart() {" >> $1
	echo "	}" >> $1
	echo "" >> $1
	echo "	public override func forStop() {" >> $1
	echo "	}" >> $1
	echo "" >> $1
	echo "	public override func inLoop() {" >> $1
	echo "	}" >> $1
	echo "" >> $1
	echo "}" >> $1
	echo "" >> $1

}

CREATE_EXT_MAKE_FILE() {

	echo "# Makefile for ${2}" >> $1
	echo "" >> $1
	echo "${2}_SWIFTC_FLAGS = \$(DEBUG) \$(\$(OS)_EXTRA_FLAGS) \\" >> $1
	echo "	-module-cache-path \$(MODULE_CACHE_PATH)/Extensions/${2} -module-name ${2} \$(\$(OS)_SWIFTC_FLAGS) \\" >> $1
	echo "	-I \$(BUILD_ROOT_DIR)/lib -I \$(BUILD_ROOT_DIR)/frameworks -F \$(BUILD_ROOT_DIR)/frameworks" >> $1
	echo "" >> $1
	echo "${2}_Src = Extensions/${2}/${2}.swift" >> $1
	echo "${2}_Obj = \$(addsuffix .o, \$(basename \$(${2}_Src)))" >> $1
	echo "${2}_Modules = \$(addprefix \$(MODULE_CACHE_PATH)/, \$(addsuffix .swiftmodule, \$(basename \$(${2}_Src))))" >> $1
	echo "" >> $1
	echo "${2}_Darwin_SHLIB_PATH = -target x86_64-apple-macosx10.10 -I\$(BUILD_ROOT_DIR)/lib -I\$(BUILD_ROOT_DIR)/frameworks \\" >> $1
	echo "	-F\$(BUILD_ROOT_DIR)/frameworks -L\$(BUILD_ROOT_DIR)/frameworks -L\$(BUILD_ROOT_DIR)/lib -L\$(SWIFT_libs) \\" >> $1
	echo "	-I/usr/include" >> $1
	echo "${2}_Linux_SHLIB_PATH = -target x86_64--linux-gnu -L\$(SWIFT_libs) \\" >> $1
	echo "	-L\$(shell dirname \$(shell dirname \$(shell which swiftc)))/lib/swift_static/linux \\" >> $1
	echo "	-L\$(BUILD_ROOT_DIR)/lib -I/usr/include" >> $1
	echo "${2}_SHLIB_PATH = \$(${2}_\$(OS)_SHLIB_PATH)" >> $1
	echo "" >> $1
	echo "${2}_Darwin_LFLAGS = \$(${2}_SHLIB_PATH) -arch x86_64 -dynamiclib \\" >> $1
	echo "	-isysroot \$(SDK) \\" >> $1
	echo "	-install_name \$(BUILD_ROOT_DIR)/extensions/lib${2}.dylib \\" >> $1
	echo "	-Xlinker -add_ast_path \\" >> $1
	echo "	-stdlib=libc++ \\" >> $1
	echo "	-Xlinker \$(SOURCE_ROOT_DIR)/Extensions/${2}/${2}.swiftmodule -single_module \\" >> $1
	echo "	-Xlinker -rpath -Xlinker @executable_path/../Frameworks \\" >> $1
	echo "	-Xlinker -rpath -Xlinker @loader_path/Frameworks \\" >> $1
	echo "	-Xlinker -rpath -Xlinker @executable_path/../lib \\" >> $1
	echo "	-Xlinker -rpath -Xlinker @executable_path/../frameworks \\" >> $1
	echo "	-compatibility_version 1 -current_version 1 \\" >> $1
	echo "	-framework Foundation -framework \$(MODULE_2_NAME) -framework \$(MODULE_1_NAME)" >> $1
	echo "${2}_Linux_LFLAGS = \$(${2}_SHLIB_PATH) -lswiftCore -lswiftGlibc -ldl -lFoundation -lbsd \\" >> $1
	echo "	-l\$(MODULE_1_NAME) -l\$(MODULE_2_NAME) -shared -fuse-ld=gold \\" >> $1
	echo "	-Xlinker -export-dynamic \\" >> $1
	echo "	-Xlinker --exclude-libs -Xlinker ALL \\" >> $1
	echo "	-Xlinker -rpath -Xlinker '\$\$ORIGIN/../lib' \\" >> $1
	echo "	\$(SWIFT_libs)/x86_64/swift_end.o" >> $1
	echo "${2}_LFLAGS = \$(${2}_\$(OS)_LFLAGS)" >> $1
	echo "" >> $1
	echo "ext-${2}-make: ext-${2}-modulecache ext-${2}.so ext-${2}-install" >> $1
	echo "" >> $1
	echo "ext-${2}-objects: $(${2}_Obj)" >> $1
	echo "" >> $1
	echo "" >> $1
}

CREATE_EXT_CONFIG_FILE() {

	echo "" >> $1
	echo "; ${2} extension config file" >> $1
	echo "; [${2}]" >> $1
	echo "; File = /usr/local" >> $1
	echo "; Enabled = 1" >> $1
	echo "" >> $1
}

GENERATE_SUB_MAKEFILE() {

	echo "" > $1
	echo "# Makefile for AllExtensions" >> $1
	echo "" >> $1

	local DIRECTORY_COUNT=0
	local DIRECTORY_LIST=(./Extensions/*)
	local DIRECTORIES;

	for ((i=0; i<${#DIRECTORY_LIST[@]}; i++)); do

		if [ -d "${DIRECTORY_LIST[$i]}" ]; then

			local FN=$(basename "${DIRECTORY_LIST[$i]}")
			DIRECTORIES[$DIRECTORY_COUNT]=$FN
			DIRECTORY_COUNT=$((DIRECTORY_COUNT + 1))
			echo "include \$(SOURCE_ROOT_DIR)/Extensions/${FN}/Makefile" >> $1
		fi
	done

	echo "" >> $1
	local ALL_EXTENSIONS_MAKE=""
	local ALL_EXTENSIONS_CLEAN=""

	for i in "${DIRECTORIES[@]}"; do

		ALL_EXTENSIONS_MAKE="${ALL_EXTENSIONS_MAKE} ext-${i}-make"
		ALL_EXTENSIONS_CLEAN="${ALL_EXTENSIONS_CLEAN} ext-${i}-clean"
	done

	echo "" >> $1
	echo "AllExtensions: ${ALL_EXTENSIONS_MAKE}" >> $1
	echo "" >> $1
	echo "AllExtensions-Clean: ${ALL_EXTENSIONS_CLEAN}" >> $1
	echo "" >> $1
}

echo "Type the extension name: "

read EXTENSION_NAME

echo ""
EXTENSION_DIRECTORY="./Extensions/${EXTENSION_NAME}"

if [ -d "$EXTENSION_DIRECTORY" ]; then

	echo "Extension ${EXTENSION_NAME} exists!"
	exit 1
else

	mkdir $EXTENSION_DIRECTORY
	CREATE_EXT_SKELL_FILE "${EXTENSION_DIRECTORY}/${EXTENSION_NAME}.swift" "${EXTENSION_NAME}.swift" "${EXTENSION_NAME}"
	CREATE_EXT_MAKE_FILE "${EXTENSION_DIRECTORY}/Makefile" "${EXTENSION_NAME}"
	CREATE_EXT_CONFIG_FILE "${EXTENSION_DIRECTORY}/Config.ini" "${EXTENSION_NAME}"
	chmod +x "${EXTENSION_DIRECTORY}/Makefile"
	GENERATE_SUB_MAKEFILE "./Extensions/MakefileSub"
	echo "Extension created!"
fi
