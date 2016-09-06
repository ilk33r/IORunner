#!/bin/bash

#  PackagesUpdater.sh
#  IORunner
#
#  Created by ilker özcan on 06/09/16.
#


echo "Updating IOGUI ..."
git -C ./Packages/IOGUI reset --hard origin/master
git -C ./Packages/IOGUI pull
echo "[OK]"

echo "Updating IOIni ..."
git -C ./Packages/IOIni reset --hard origin/master
git -C ./Packages/IOGUI pull
echo "[OK]"

exit 0
