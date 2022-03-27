//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation


/// A sequence that are used to iterate over every pair of elements in two different sequences.
public struct Product2Sequence<Base1: Sequence, Base2: Sequence>: Sequence, IteratorProtocol {
    let base1: Base1
    let base2: Base2
    
    public init(_ base1: Base1, _ base2: Base2) {
        self.base1 = base1
        self.base2 = base2
        
        self.base1Iterator = self.base1.makeIterator()
        self.base2Iterator = self.base2.makeIterator()
        
        self.currentBase1Element = base1Iterator.next()
    }
    
    var base1Iterator: Base1.Iterator
    var base2Iterator: Base2.Iterator
    var currentBase1Element: Base1.Element?
    
    mutating public func next() -> (Base1.Element, Base2.Element)? {
        guard currentBase1Element != nil else {
            return nil
        }
        
        if let nextBase2Element = base2Iterator.next() {
            return (currentBase1Element!, nextBase2Element)
        }
        
        base2Iterator = base2.makeIterator()
        
        if let nextBase1Element = base1Iterator.next() {
            currentBase1Element = nextBase1Element
            
            if let nextBase2Element = base2Iterator.next() {
                return (nextBase1Element, nextBase2Element)
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
}


/// Returns a sequence that are used to iterate over every pair of elements in two different sequences.
public func product<Base1: Sequence, Base2: Sequence>(_ base1: Base1, _ base2: Base2) -> Product2Sequence<Base1, Base2> {
    .init(base1, base2)
}
