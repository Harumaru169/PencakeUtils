//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol ParallelPhotosLoaderProtocol {
    func loadAllPhotos(in directoryURL: URL) async throws -> [Photo]
    
    func loadPhotos(ofArticleNumber specifiedArticleNumber: Int, in directoryURL: URL) async throws -> [Photo]
}
