//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol NewlineReplacerProtocol {
    func replaceAll(in: inout String, with: Newline)
    
    func replacingAll(in: String, with: Newline) -> String
}
