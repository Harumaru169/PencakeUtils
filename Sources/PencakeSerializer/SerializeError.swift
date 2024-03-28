//
//
// The MIT License (MIT)
//
// Copyright (c) 2024 Kosei Haruyama.
//

import Foundation
import PencakeCore

public enum SerializeError: Error, CustomStringConvertible {
    case fileAlreadyExists(URL)
    
    public var description: String {
        return switch self {
        case .fileAlreadyExists(let url): "A file already exists at \(url.path())"
        }
    }
}
