//
//  NewlineReplacer.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation
import Regex

public final class NewlineReplacer: NewlineReplacerProtocol {
    
    public init() {}
    
    private static let regex: Regex = try! .init(pattern: "\r\n|\n|\r")
    
    public func replaceAll(in originalString: inout String, with newline: Newline) {
        originalString = Self.regex.replaceAll(in: originalString, with: newline.rawString)
    }
    
    public func replacingAll(in originalString: String, with newline: Newline) -> String {
        return Self.regex.replaceAll(in: originalString, with: newline.rawString)
    }
}
