//
//  InstallData.s
//  IORunner
//
//  Created by ilker özcan on 13/08/16.
//
//

	.global _InstallData_Data
	.global _InstallData_Size
_InstallData_Data:
	.incbin "Build/IORunnerInstallData"
1:
_InstallData_Size:
	.int 1b - _InstallData_Data
