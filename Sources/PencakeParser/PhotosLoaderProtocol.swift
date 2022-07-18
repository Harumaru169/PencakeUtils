//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol PhotosLoaderProtocol {
    func loadAllPhotos(in directoryURL: URL) throws -> [Photo]
    
    func loadPhotos(ofArticleNumber specifiedArticleNumber: Int, in directoryURL: URL) throws -> [Photo]
}
