// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation

public enum Newline: String, RawRepresentable, CaseIterable, Codable, Sendable {
    case cr
    case lf
    case crlf
}

extension Newline {
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
