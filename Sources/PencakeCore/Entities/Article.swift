//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

public struct Article: Codable, Equatable, Sendable {
    public var title: String
    
    public var editDate: Date
    
    public var body: String
    
    public var photos: [Photo]
    
    public init(title: String, editDate: Date, body: String, photos: [Photo] = []) {
        self.title = title
        self.editDate = editDate
        self.body = body
        self.photos = photos
    }
}
