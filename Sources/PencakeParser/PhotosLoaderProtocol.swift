//
//  PhotosLoaderProtocol.swift
//  
//
//  Created by k.haruyama on 2022/02/19.
//  
//

import Foundation
import PencakeCore

public protocol PhotosLoaderProtocol: Decodable, Sendable {
    // When articleNumber is specified, loads the corresponding photo; when it is not specified, loads all photos.
    func load(from: URL, articleNumber: Int?) async throws -> [Photo]
}
