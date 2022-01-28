//
//  ParseOptions.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation

public struct ParseOptions {
    public var language: Language
    public var newlineCharacter: NewlineCharacter?
    
    public init(
        language: Language,
        replaceNewlineCharWith newlineCharacter: NewlineCharacter? = nil
    ) {
        self.language = language
        self.newlineCharacter = newlineCharacter
    }
}
