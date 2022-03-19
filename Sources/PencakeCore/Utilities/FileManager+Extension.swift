//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

extension FileManager {
    public func type(atPath path: String) throws -> FileAttributeType {
        let attributes = try self.attributesOfItem(atPath: path)
        return attributes[.type] as! FileAttributeType
    }
    
    public func type(at url: URL) throws -> FileAttributeType {
        return try self.type(atPath: url.path)
    }
}
