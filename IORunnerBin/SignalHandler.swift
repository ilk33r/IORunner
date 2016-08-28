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

typealias SignalAction = sigaction

internal final class SignalHandler {

	enum Signal: Int32 {
		case Hup = 1
		case Interrupt = 2
		case Quit = 3
		case Abort = 6
		case Kill = 9
		case TTIN = 21
		case TTOU = 22
		case Terminate = 15
		case Child = 20
		case Usr1 = 30
		case Usr2 = 31
	}

	class func registerSignals() {
	#if swift(>=3)
		
		signal(SIGTERM) { _ in sharedHandler?.handle(signal: .Terminate) }
		signal(SIGINT) { _ in sharedHandler?.handle(signal: .Interrupt) }
		signal(SIGQUIT) { _ in sharedHandler?.handle(signal: .Quit) }
		signal(SIGTTIN) { _ in sharedHandler?.handle(signal: .TTIN) }
		signal(SIGTTOU) { _ in sharedHandler?.handle(signal: .TTOU) }
		signal(SIGCHLD) { _ in sharedHandler?.handle(signal: .Child) }
	#elseif swift(>=2.2) && os(OSX)
		
		signal(SIGTERM) { _ in sharedHandler?.handle(.Terminate) }
		signal(SIGINT) { _ in sharedHandler?.handle(.Interrupt) }
		signal(SIGQUIT) { _ in sharedHandler?.handle(.Quit) }
		signal(SIGTTIN) { _ in sharedHandler?.handle(.TTIN) }
		signal(SIGTTOU) { _ in sharedHandler?.handle(.TTOU) }
		signal(SIGCHLD) { _ in sharedHandler?.handle(.Child) }
	#endif
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

	func register(signal: Signal, _ callback: (() -> ())) {
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
	
	/*
	func trapSignal(handler: sig_t, flags: Int32, signal: Signal) {
	
		var signalAction = SignalAction(__sigaction_u: unsafeBitCast(handler, to: __sigaction_u.self), sa_mask: 0, sa_flags: flags)
		sigaction(signal.rawValue, &signalAction, nil)
	}
	
	func suspend() {
		sigsuspend(nil)
	}
	*/
}
