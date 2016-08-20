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
#	define RUNNER_CONFIG_INI "[Daemonize]\n"\
							"Daemonize=1\n"\
							"Pid=%s\n"\
							"\n"\
							"[Logging]\n"\
							"; 0 (minimal), 1 (errors), 2 (errors + warnings)\n"\
							"LogLevel=0\n"\
							"; extension must be logfiles\n"\
							"LogFile=%s\n"\
							"MaxLogSize=100000000\n"\
							"\n"\
							"[Extensions]\n"\
							"ExtensionsDir=%s\n"\
							"\n\n"
#endif

#ifndef RUNNER_SHORTCUT_BASH
#	define RUNNER_SHORTCUT_BASH "#!/bin/sh\n"\
								"\n"\
								"#  " APP_PACKAGE_NAME "\n"\
								"#\n"\
								"#  Created by " INSTALLER_PACKAGE_NAME "\n"\
								"#\n"\
								"\n"\
								"APPLICATION_NAME=\"" APP_PACKAGE_NAME "\"\n"\
								"APPLICATION_BASE_DIRECTORY=\"%s\"\n"\
								"CONFIG_FILE_PATH=\"${APPLICATION_BASE_DIRECTORY}/etc/Config.ini\"\n"\
								"APPLICATION_BINARY_DIR=\"${APPLICATION_BASE_DIRECTORY}/bin/${APPLICATION_NAME}\"\n"\
								"\n"\
								"MODE=0\n"\
								"SIGNAL=\"\"\n"\
								"\n"\
								"for i in \"$@\"\n"\
								"do\n"\
								"	case $i in\n"\
								"		--isInstalled)\n"\
								"			MODE=1\n"\
								"			shift # past argument=value\n"\
								"			;;\n"\
								"		--signal=*)\n"\
								"			MODE=2\n"\
								"			SIGNAL=\"${i#*=}\"\n"\
								"			shift # past argument=value\n"\
								"			;;\n"\
								"		*)\n"\
								"			MODE=0\n"\
								"			# unknown option\n"\
								"			;;\n"\
								"	esac\n"\
								"done\n"\
								"\n"\
								"if [ $MODE -eq 0 ] ; then\n"\
								"\n"\
								"	eval \"${APPLICATION_BINARY_DIR} --config ${CONFIG_FILE_PATH}\"\n"\
								"	exit 0\n"\
								"\n"\
								"elif [ $MODE -eq 1 ] ; then\n"\
								"\n"\
								"	echo \"${APPLICATION_BASE_DIRECTORY}\"\n"\
								"	echo \"\"\n"\
								"	exit 0\n"\
								"\n"\
								"elif [ $MODE -eq 2 ] ; then\n"\
								"\n"\
								"	eval \"${APPLICATION_BINARY_DIR} --config ${CONFIG_FILE_PATH} --onlyusearguments --signal ${SIGNAL}\"\n"\
								"	exit 0\n"\
								"\n"\
								"fi\n"\
								"\n\n"
#endif

#ifdef BUILD_OS_Darwin

#	ifndef RUNNER_DARWIN_SERVICE
#		define RUNNER_DARWIN_SERVICE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
									"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n"\
									"<dict>\n"\
									"	<key>Label</key>\n"\
									"	<string>com.ilkerozcan.iorunner</string>\n"\
									"	<key>ProgramArguments</key>\n"\
									"		<array>\n"\
									"			<string>%s/bin/IORunner</string>\n"\
									"			<string>--config</string>\n"\
									"			<string>%s/etc/Config.ini</string>\n"\
									"			<string>--keepalive</string>\n"\
									"		</array>\n"\
									"	<key>UserName</key>\n"\
									"	<string>root</string>\n"\
									"	<key>RunAtLoad</key>\n"\
									"	<true/>\n"\
									"	<key>KeepAlive</key>\n"\
									"	<dict>\n"\
									"		<key>SuccessfulExit</key>\n"\
									"		<false/>\n"\
									"	</dict>\n"\
									"	<key>ServiceIPC</key>\n"\
									"	<true/>\n"\
									"</dict>\n"\
									"</plist>\n\n"
#	endif

#	ifndef RUNNER_DARWIN_SERVICE_PATH
#		define RUNNER_DARWIN_SERVICE_PATH "/Library/LaunchDaemons/"
#	endif

#elif defined BUILD_OS_Linux

#	ifndef RUNNER_LINUX_SERVICE
#		define RUNNER_LINUX_SERVICE "#! /bin/sh\n"\
									"\n"\
									"### BEGIN INIT INFO\n"\
									"# Provides:          " APP_PACKAGE_NAME "\n"\
									"# Required-Start:    $local_fs $remote_fs $network $named $time $syslog\n"\
									"# Required-Stop:     $local_fs $remote_fs $network $named $time $syslog\n"\
									"# Default-Start:     2 3 4 5\n"\
									"# Default-Stop:      0 1 6\n"\
									"# Short-Description: starts " APP_PACKAGE_NAME "\n"\
									"# Description:       starts the " APP_PACKAGE_NAME " daemon\n"\
									"### END INIT INFO\n"\
									"\n"\
									"BASE_PATH=\"%s\"\n"\
									"APP_PACKAGE_NAME=\"" APP_PACKAGE_NAME "\"\n"\
									"\n"\
									"SCRIPT=\"${BASE_PATH}/bin/${APP_PACKAGE_NAME}\"\n"\
									"RUNAS=root\n"\
									"\n"\
									"PIDFILE=\"${BASE_PATH}/var/run/${APP_PACKAGE_NAME}.pid\"\n"\
									"CONFIG_FILE=\"${BASE_PATH}/etc/Config.ini\"\n"\
									"\n"\
									"start() {\n"\
									"\n"\
									"	echo 'Starting service…' >&2\n"\
									"	su -c \"${SCRIPT} --config ${CONFIG_FILE} --onlyusearguments --signal start\" $RUNAS >&1\n"\
									"}\n"\
									"\n"\
									"stop() {\n"\
									"\n"\
									"	echo 'Stopping service…' >&2\n"\
									"	su -c \"${SCRIPT} --config ${CONFIG_FILE} --onlyusearguments --signal stop\" $RUNAS >&1\n"\
									"}\n"\
									"\n"\
									"status() {\n"\
									"\n"\
									"	if [ ! -r PIDFILE ] ; then\n"\
									"		echo \"${APP_PACKAGE_NAME} is stopped\"\n"\
									"		exit 0\n"\
									"	fi\n"\
									"\n"\
									"	local PID=`cat ${PIDFILE}`\n"\
									"\n"\
									"	if ps -p $PID | grep -q $PID; then\n"\
									"		echo \"${APP_PACKAGE_NAME} (pid $PID) is running...\"\n"\
									"	else\n"\
									"		echo \"${APP_PACKAGE_NAME} dead but pid file exists\"\n"\
									"	fi\n"\
									"}\n"\
									"\n"\
									"restart() {\n"\
									"\n"\
									"	echo 'Restarting service…' >&2\n"\
									"	su -c \"${SCRIPT} --config ${CONFIG_FILE} --onlyusearguments --signal restart\" $RUNAS >&1\n"\
									"}\n"\
									"\n"\
									"forcestop() {\n"\
									"\n"\
									"	echo 'Stopping service…' >&2\n"\
									"	su -c \"${SCRIPT} --config ${CONFIG_FILE} --onlyusearguments --signal force-stop\" $RUNAS >&1\n"\
									"}\n"\
									"\n"\
									"install() {\n"\
									"\n"\
									"	echo -n \"Are you really sure you want to install this service? [yes|No] \"\n"\
									"	local SURE\n"\
									"	read SURE\n"\
									"\n"\
									"	if [ \"$SURE\" = \"yes\" ]; then\n"\
									"		stop\n"\
									"		update-rc.d $APP_PACKAGE_NAME defaults\n"\
									"	fi\n"\
									"}\n"\
									"\n"\
									"uninstall() {\n"\
									"\n"\
									"	echo -n \"Are you really sure you want to uninstall this service? [yes|No] \"\n"\
									"	local SURE\n"\
									"	read SURE\n"\
									"\n"\
									"	if [ \"$SURE\" = \"yes\" ]; then\n"\
									"		stop\n"\
									"		update-rc.d -f $$APP_PACKAGE_NAME remove\n"\
									"fi\n"\
									"}\n"\
									"\n"\
									"case \"$1\" in\n"\
									"	start)\n"\
									"		start\n"\
									"		;;\n"\
									"	stop)\n"\
									"		stop\n"\
									"		;;\n"\
									"	status)\n"\
									"		status\n"\
									"		;;\n"\
									"	retart)\n"\
									"		restart\n"\
									"		;;\n"\
									"	force-stop)\n"\
									"		forcestop\n"\
									"		;;\n"\
									"	install)\n"\
									"		install\n"\
									"		;;\n"\
									"	uninstall)\n"\
									"		uninstall\n"\
									"		;;\n"\
									"	*)\n"\
									"		echo \"Usage: $0 {start|stop|status|restart|force-stop|install|uninstall}\"\n"\
									"esac\n"\
									"\n"\
									"\n\n"
#	endif

#	ifndef RUNNER_LINUX_SERVICE_PATH
#		define RUNNER_LINUX_SERVICE_PATH "/etc/init.d/"
#	endif

#endif

#endif /* ConfigFile_h */
