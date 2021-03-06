//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol StoryParserProtocol: Decodable, Sendable {
    func parse(directoryURL: URL, options: ParseOptions) throws -> Story
    
    func parse(zipFileURL: URL, options: ParseOptions) throws -> Story
}
