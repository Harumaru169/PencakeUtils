// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation
import PencakeCore

public struct ParseOptions: Codable, Sendable {
    public var language: Language
    public var newline: Newline?
    
    public init(
        language: Language,
        newline: Newline? = nil
    ) {
        self.language = language
        self.newline = newline
    }
}
