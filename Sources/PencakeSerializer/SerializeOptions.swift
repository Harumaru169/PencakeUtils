//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public struct SerializeOptions: Codable, Sendable {
    public var language: Language
    public var newline: Newline
    public var locale: Locale
    
    public init(language: Language, newline: Newline, locale: Locale) {
        self.language = language
        self.newline = newline
        self.locale = locale
    }
}
