//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol ParallelStoryParserProtocol {
    func parse(directoryURL: URL, options: ParseOptions) async throws -> Story
    
    func parse(zipFileURL: URL, options: ParseOptions) async throws -> Story
}
