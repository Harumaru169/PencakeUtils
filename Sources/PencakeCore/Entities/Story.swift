//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

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
