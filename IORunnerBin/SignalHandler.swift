//
//  Signals.swift
//  IORunner
//
//  Created by ilker özcan on 04/07/16.
//
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

var sharedHandler: SignalHandler?

internal final class SignalHandler {

	enum Signal {
		case Interrupt
		case Quit
		case TTIN
		case TTOU
		case Terminate
		case Child
	}

	class func registerSignals() {
		/* ## Swift 3
		signal(SIGTERM) { _ in sharedHandler?.handle(signal: .Terminate) }
		signal(SIGINT) { _ in sharedHandler?.handle(signal: .Interrupt) }
		signal(SIGQUIT) { _ in sharedHandler?.handle(signal: .Quit) }
		signal(SIGTTIN) { _ in sharedHandler?.handle(signal: .TTIN) }
		signal(SIGTTOU) { _ in sharedHandler?.handle(signal: .TTOU) }
		signal(SIGCHLD) { _ in sharedHandler?.handle(signal: .Child) }
		*/
		signal(SIGTERM) { _ in sharedHandler?.handle(.Terminate) }
		signal(SIGINT) { _ in sharedHandler?.handle(.Interrupt) }
		signal(SIGQUIT) { _ in sharedHandler?.handle(.Quit) }
		signal(SIGTTIN) { _ in sharedHandler?.handle(.TTIN) }
		signal(SIGTTOU) { _ in sharedHandler?.handle(.TTOU) }
		signal(SIGCHLD) { _ in sharedHandler?.handle(.Child) }
	}

	class func reset() {
		signal(SIGTERM, SIG_DFL)
		signal(SIGINT, SIG_DFL)
		signal(SIGQUIT, SIG_DFL)
		signal(SIGTTIN, SIG_DFL)
		signal(SIGTTOU, SIG_DFL)
		signal(SIGCHLD, SIG_DFL)
	}

	var signalQueue: [Signal] = []
	var callbacks: [Signal: () -> ()] = [:]

	init() {
		sharedHandler = self
	}

	func handle(signal: Signal) {
		signalQueue.append(signal)
	}

	func register(signal: Signal, _ callback: () -> ()) {
		callbacks[signal] = callback
	}

	func process() -> Bool {
		
		let result = !signalQueue.isEmpty

		if !signalQueue.isEmpty {
			
			if let handler = callbacks[signalQueue.removeFirst()] {
				handler()
			}
		}

		return result
	}
}
