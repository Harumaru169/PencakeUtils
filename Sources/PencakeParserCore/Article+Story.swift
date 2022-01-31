//
//  Article+Story.swift
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
    
    public init(title: String, editDate: Date, body: String) {
        self.title = title
        self.editDate = editDate
        self.body = body
    }
}

public struct Story: Codable, Equatable, Sendable {
    public var title: String
    
    public var subtitle: String
    
    public var createdDate: Date
    
    public var exportedDate: Date
    
    public var articles: [Article]
    
    public init(title: String, subtitle: String, createdDate: Date, exportedDate: Date, articles: [Article]) {
        self.title = title
        self.subtitle = subtitle
        self.createdDate = createdDate
        self.exportedDate = exportedDate
        self.articles = articles
    }
}
