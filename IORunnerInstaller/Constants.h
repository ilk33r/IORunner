//
//  Constants.h
//
//  Created by ilker özcan on 28/07/16.
//
//

#ifndef Constants_h
#define Constants_h

#ifndef APP_NAME
#	define APP_NAME "IO"
#endif

#ifndef APP_PACKAGE_NAME
#	define APP_PACKAGE_NAME "IOApp"
#endif

#ifndef APP_VERSION
#	define APP_VERSION "1.0.0"
#endif

#ifndef INSTALLER_PACKAGE_NAME
#	define INSTALLER_PACKAGE_NAME "IOInstaller"
#endif

#ifndef WELCOME_STRING
#	define WELCOME_STRING "Welcome to the " APP_NAME " V" APP_VERSION " Installer\n"
#endif

#ifndef USAGE_STRING
#	define USAGE_STRING "Usage\n\t" INSTALLER_PACKAGE_NAME " [Install Path]\n\n"
#endif

#ifndef PROCESS_IS_INSTALLED_COMMAND
#	define PROCESS_IS_INSTALLED_COMMAND "/usr/local/bin/" APP_PACKAGE_NAME " --isInstalled"
#endif

#endif /* Constants_h */
