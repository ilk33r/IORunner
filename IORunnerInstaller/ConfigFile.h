//
//  ConfigFile.h
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#ifndef ConfigFile_h
#define ConfigFile_h

#ifndef RUNNER_CONFIG_INI
#	define RUNNER_CONFIG_INI "[Daemonize]\nDaemonize=1\nPid=%s\n\n[Logging]\n; 0 (minimal), 1 (errors), 2 (errors + warnings)\nLogLevel=0\n; extension must be logfiles\nLogFile=%s\nMaxLogSize=100000000\n\n[Extensions]\nExtensionsDir=%s\n"
#endif

#ifndef RUNNER_SHORTCUT_BASH
#	define RUNNER_SHORTCUT_BASH "#!/bin/sh\n\n#  " APP_PACKAGE_NAME "\n#  " APP_PACKAGE_NAME "\n#\n#  Created by IORunnerInstaller\n#\n\nAPPLICATION_NAME=\"" APP_PACKAGE_NAME "\"\nAPPLICATION_BASE_DIRECTORY=\"%s\"\nCONFIG_FILE_PATH=\"${APPLICATION_BASE_DIRECTORY}/etc/Config.ini\"\nAPPLICATION_BINARY_DIR=\"${APPLICATION_BASE_DIRECTORY}/bin/${APPLICATION_NAME}\"\n\nMODE=0\nSIGNAL=\"\"\n\nfor i in \"$@\"\ndo\n\tcase $i in\n\t\t--isInstalled)\n\t\t\tMODE=1\n\t\t\tshift # past argument=value\n\t\t\t;;\n\t\t--signal=*)\n\t\t\tMODE=2\n\t\t\tSIGNAL=\"${i#*=}\"\n\t\t\tshift # past argument=value\n\t\t\t;;\n\t\t*)\n\t\t\tMODE=0\n\t\t\t# unknown option\n\t\t\t;;\n\tesac\ndone\n\nif [ $MODE -eq 0 ] ; then\n\n\teval \"${APPLICATION_BINARY_DIR} --config ${CONFIG_FILE_PATH}\"\n\texit 0\n\nelif [ $MODE -eq 1 ] ; then\n\n\techo \"${APPLICATION_BASE_DIRECTORY}\"\n\techo \"\"\n\texit 0\n\nelif [ $MODE -eq 2 ] ; then\n\n\teval \"${APPLICATION_BINARY_DIR} --config ${CONFIG_FILE_PATH} --onlyusearguments --signal ${SIGNAL}\"\n\texit 0\n\nfi\n\n"
#endif

#endif /* ConfigFile_h */
