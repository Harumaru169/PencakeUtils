// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation
import PencakeCore

public protocol ArticleParserProtocol: Decodable, Sendable {
    func parse(from: Data, options: ParseOptions) async throws -> Article
    
    func parse(fileURL: URL, options: ParseOptions) async throws -> Article
}
