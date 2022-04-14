//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore

public protocol PencakeComponent {
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
