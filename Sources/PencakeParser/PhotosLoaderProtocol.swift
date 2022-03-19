// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation
import PencakeCore

public protocol PhotosLoaderProtocol: Decodable, Sendable {
    // When articleNumber is specified, loads the corresponding photo; when it is not specified, loads all photos.
    func load(from: URL, articleNumber: Int?) async throws -> [Photo]
}
