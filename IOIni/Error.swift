//
//  Error.swift
//  IORunner/IOIni
//
//  Created by ilker özcan on 22/07/16.
//
//

import Foundation

/* ## Swift 3
enum ScanError: ErrorProtocol {
    case NoMatch
}
enum ParseError: ErrorProtocol {
    case InvalidSyntax(Scanner.Position)
    case UnsupportedToken(Scanner.Position)
}

extension ParseError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .InvalidSyntax(_, row, pos): return "Invalid syntax at row \(row), position \(pos)"
        case let .UnsupportedToken(_, row, pos): return "Unsupported token at row \(row), position \(pos)"
        }
    }
}
*/

enum ParseError: ErrorType {
	
	case InvalidSyntax(err: String)
	case UnsupportedToken(err: String)
}