#!/bin/bash

#  PackagesUpdater.sh
#  IORunner
#
#  Created by ilker özcan on 06/09/16.
#


echo "Updating IOGUI ..."
if [[ -d ./Packages/IOGUI ]]; then

	git -C ./Packages/IOGUI reset --hard origin/master
	git -C ./Packages/IOGUI pull

else

	git -C ./Packages clone https://github.com/ilk33r/IOGUI.git

fi
echo "[OK]"


echo "Updating IOIni ..."
if [[ -d ./Packages/IOIni ]]; then

	git -C ./Packages/IOIni reset --hard origin/master
	git -C ./Packages/IOIni pull

else

	git -C ./Packages clone https://github.com/ilk33r/IOIni.git

fi
echo "[OK]"


exit 0
