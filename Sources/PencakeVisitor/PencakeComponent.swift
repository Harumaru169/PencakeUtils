//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

/// A component of PenCake data.
public protocol PencakeComponent {
    /// Accept a `PencakeVisitor` and call the specific visitation method for this element.
    /// - Parameter visitor: The `PencakeVisitor` visiting the component.
    /// - Returns: The result of the visit.
    func accept<V: PencakeVisitor>(_ visitor: inout V) -> V.Result
}

//MARK: - Protocol Conformance

extension Article: PencakeComponent {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : PencakeVisitor {
        visitor.visitArticle(self)
    }
}

extension StoryInformation: PencakeComponent {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : PencakeVisitor {
        visitor.visitStoryInformation(self)
    }
}

extension Photo: PencakeComponent {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : PencakeVisitor {
        visitor.visitPhoto(self)
    }
}

extension Story: PencakeComponent {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : PencakeVisitor {
        visitor.visitStory(self)
    }
}
