//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public struct GenerateOptions {
    public var language: Language
    public var newline: Newline
    
    public init(language: Language, newline: Newline) {
        self.language = language
        self.newline = newline
    }
}

extension GenerateOptions: CaseIterable {
    public static let allCases: [GenerateOptions] = {
        product(Language.allCases, Newline.allCases)
            .map(GenerateOptions.init(language:newline:))
    }()
}
