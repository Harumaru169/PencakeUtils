//
//  Article.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
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
