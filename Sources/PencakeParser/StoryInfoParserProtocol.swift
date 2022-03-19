//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol StoryInfoParserProtocol: Decodable, Sendable {
    func parse(from: Data) async throws -> StoryInformation
    
    func parse(fileURL: URL) async throws -> StoryInformation
}
