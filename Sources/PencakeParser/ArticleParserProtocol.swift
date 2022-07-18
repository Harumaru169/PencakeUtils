//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol ArticleParserProtocol {
    func parse(from: Data, options: ParseOptions) throws -> Article
    
    func parse(fileURL: URL, options: ParseOptions) throws -> Article
}
