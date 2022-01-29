//
//  ParseOptions.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation

public struct ParseOptions: Codable {
    public var language: Language
    public var newline: Newline?
    
    public init(
        language: Language,
        newline: Newline? = nil
    ) {
        self.language = language
        self.newline = newline
    }
}
