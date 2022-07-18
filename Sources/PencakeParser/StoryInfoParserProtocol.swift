//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol StoryInfoParserProtocol {
    func parse(from: Data) throws -> StoryInfo
    
    func parse(fileURL: URL) throws -> StoryInfo
}
