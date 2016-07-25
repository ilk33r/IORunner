//
//  InstallData.c
//  IORunner/Installer
//
//  Created by ilker özcan on 21/07/16.
//
//

#include "InstallData.h"
#include "InstallDataEx.h"

int getAssetSize() {
	return Build_IORunnerInstallData_len;
}

unsigned char getAssetByte(int byteIdx) {
	return Build_IORunnerInstallData[byteIdx];
}
