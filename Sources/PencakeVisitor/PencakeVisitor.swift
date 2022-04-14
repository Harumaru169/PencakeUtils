//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

/// An object that visits `PencakeComponent`s and returns a result.
public protocol PencakeVisitor {
    associatedtype Result
    
    
    /// Visit a `PencakeComponent`.
    /// - Parameter component: The `PencakeComponent` this visitor should visit.
    /// - Returns: The result of the visit.
    mutating func visit(_ component: any PencakeComponent) -> Result
    
    
    /// A default implementation to use when a visitor method isn't implemented for a particular component.
    /// - Parameter component: The component this visitor should visit.
    /// - Returns: The result of the visit.
    mutating func defaultVisit(_ component: any PencakeComponent) -> Result
    
    mutating func visitArticle(_ article: Article) -> Result
    
    mutating func visitStoryInformation(_ storyInformation: StoryInformation) -> Result
    
    mutating func visitPhoto(_ photo: Photo) -> Result
    
    mutating func visitStory(_ story: Story) -> Result
    
}

extension PencakeVisitor {
    public mutating func visit(_ component: any PencakeComponent) -> Result {
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
