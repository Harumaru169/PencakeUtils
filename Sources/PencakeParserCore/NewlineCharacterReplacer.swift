//
//  NewlineCharacterReplacer.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation
import Regex

public struct NewlineCharacterReplacer: NewlineCharacterReplacerProtocol {
    
    public init() {}
    
    private static let regex: Regex = try! .init(pattern: "\r\n|\n|\r")
    
    public func replaceAll(in originalString: inout String, with newlineCharacter: NewlineCharacter) {
        originalString = Self.regex.replaceAll(in: originalString, with: newlineCharacter.rawString)
    }
    
    public func replacingAll(in originalString: String, with newlineCharacter: NewlineCharacter) -> String {
        return Self.regex.replaceAll(in: originalString, with: newlineCharacter.rawString)
    }
}
