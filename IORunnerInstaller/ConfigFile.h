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

#ifdef BUILD_OS_Darwin
#	ifndef RUNNER_DARWIN_SERVICE
#		define RUNNER_DARWIN_SERVICE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>Label</key>\n\t<string>com.ilkerozcan.iorunner</string>\n\t<key>ProgramArguments</key>\n\t<array>\n\t\t<string>%s/bin/IORunner</string>\n\t\t<string>--config</string>\n\t\t<string>%s/etc/Config.ini</string>\n\t\t<string>--onlyusearguments</string>\n\t\t<string>--signal</string>\n\t\t<string>start</string>\n\t\t<string>--keepalive</string>\n\t</array>\n\t<key>UserName</key>\n\t<string>root</string>\n\t<key>RunAtLoad</key>\n\t<true/>\n\t<key>KeepAlive</key>\n\t<dict>\n\t\t<key>SuccessfulExit</key>\n\t\t<false/>\n\t</dict>\n\t<key>ServiceIPC</key>\n\t<true/>\n</dict>\n</plist>"
#	endif

#	ifndef RUNNER_DARWIN_SERVICE_PATH
#		define RUNNER_DARWIN_SERVICE_PATH "/Library/LaunchDaemons/"
#	endif

#endif

#endif /* ConfigFile_h */
