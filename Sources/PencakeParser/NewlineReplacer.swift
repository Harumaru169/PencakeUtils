//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public final class NewlineReplacer: NewlineReplacerProtocol {
    
    public init() {}
    
    private static let regex = try! Regex("\r\n|\n|\r")
    
    public func replaceAll(in originalString: inout String, with newline: Newline) {
        originalString = originalString.replacing(Self.regex, with: { _ in newline.rawString})
    }
    
    public func replacingAll(in originalString: String, with newline: Newline) -> String {
        originalString.replacing(Self.regex, with: { _ in newline.rawString})
    }
}
