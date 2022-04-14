//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import Regex

extension Newline {
    public static var regexMatchingAnyNewline: String {
        allCases.map(\.rawString).joined(separator: "|")
    }
}
