//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

public struct StoryInfo: Equatable {
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
    // 'storyInfo.articleCount' will be ignored.
    public init(storyInfo: StoryInfo, articles: [Article]) {
        self.title = storyInfo.title
        self.subtitle = storyInfo.subtitle
        self.createdDate = storyInfo.createdDate
        self.exportedDate = storyInfo.exportedDate
        self.articles = articles
    }
}
