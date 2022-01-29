//
//  NewlineCharacter.swift
//  
//
//  Created by k.haruyama on 2022/01/24.
//  
//

import Foundation

public enum NewlineCharacter: String, RawRepresentable, CaseIterable, Codable {
    case cr
    case lf
    case crlf
}

extension NewlineCharacter {
    public var rawString: String {
        switch self {
            case .cr:
                return "\r"
            case .lf:
                return "\n"
            case .crlf:
                return "\r\n"
        }
    }
    
    public func commonName(abbreviated: Bool) -> String {
        if abbreviated {
            switch self {
                case .cr:
                    return "CR"
                case .lf:
                    return "LF"
                case .crlf:
                    return "CRLF"
            }
        } else {
            switch self {
                case .cr:
                    return "Carriage Return"
                case .lf:
                    return "Line Feed"
                case .crlf:
                    return "Carriage Return + Line Feed"
            }
        }
    }
}
