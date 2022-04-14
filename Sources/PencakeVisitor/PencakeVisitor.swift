//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol PencakeVisitor {
    associatedtype Result
    
    mutating func visit(_ component: PencakeComponent) -> Result
    
    mutating func defaultVisit(_ component: PencakeComponent) -> Result
    
    mutating func visitArticle(_ article: Article) -> Result
    
    mutating func visitStoryInformation(_ storyInformation: StoryInformation) -> Result
    
    mutating func visitPhoto(_ photo: Photo) -> Result
    
    mutating func visitStory(_ story: Story) -> Result

}

extension PencakeVisitor {
    public mutating func visit(_ component: PencakeComponent) -> Result {
        component.accept(&self)
    }
    
    public mutating func visitArticle(_ article: Article) -> Result {
        defaultVisit(article)
    }
    
    public mutating func visitStoryInformation(_ storyInformation: StoryInformation) -> Result {
        defaultVisit(storyInformation)
    }
    
    public mutating func visitPhoto(_ photo: Photo) -> Result {
        defaultVisit(photo)
    }
    
    public mutating func visitStory(_ story: Story) -> Result {
        defaultVisit(story)
    }
}
