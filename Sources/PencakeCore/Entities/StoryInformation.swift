// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation

public struct StoryInformation: Equatable {
    public var title: String
    
    public var subtitle: String
    
    public var createdDate: Date
    
    public var exportedDate: Date
    
    public var articleCount: Int
    
    public init(title: String, subtitle: String, createdDate: Date, exportedDate: Date, articleCount: Int) {
        self.title = title
        self.subtitle = subtitle
        self.createdDate = createdDate
        self.exportedDate = exportedDate
        self.articleCount = articleCount
    }
}

extension Story {
    // 'information.articleCount' will be ignored.
    public init(information: StoryInformation, articles: [Article]) {
        self.title = information.title
        self.subtitle = information.subtitle
        self.createdDate = information.createdDate
        self.exportedDate = information.exportedDate
        self.articles = articles
    }
}
