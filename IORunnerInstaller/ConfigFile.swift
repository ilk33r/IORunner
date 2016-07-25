//
//  ConfigFile.swift
//  IORunner/Installer
//
//  Created by ilker özcan on 20/07/16.
//
//

let daemonizeConfigData = "[Daemonize]\nDaemonize=1\nPid="

let loggingConfigDataStart = "[Logging]\n; 0 (minimal), 1 (errors), 2 (errors + warnings)\nLogLevel=0\n; extension must be logfiles\nLogFile="
let loggingConfigDataEnd="MaxLogSize=100000000\n\n"

let extensionsConfigData = "[Extensions]\nExtensionsDir="
