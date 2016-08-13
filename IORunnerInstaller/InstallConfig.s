//
//  InstallConfig.s
//  IORunner
//
//  Created by ilker özcan on 13/08/16.
//
//

	.global _InstallConfig
	.global _InstallConfig_Size
_InstallConfig:
	.incbin "Build/IORunnerInstallConfig"
1:
_InstallConfig_Size:
	.int 1b - _InstallConfig
