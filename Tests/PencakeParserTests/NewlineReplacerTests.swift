//
//  NewlineReplacerTests.swift
//  
//
//  Created by k.haruyama on 2022/01/28.
//  
//

import XCTest
@testable import PencakeParser

class NewlineReplacerTests: XCTestCase {

    func testFuncInAllCombinations() throws {
        let replacer = NewlineReplacer()
        
        for newline in Newline.allCases {
            for originalNewline in Newline.allCases {

                let originalString = Self.testStringDictionary[originalNewline]!
                let testString = Self.testStringDictionary[newline]!
                
                let result = replacer.replacingAll(in: originalString, with: newline)
                
                XCTAssertEqual(result, testString)
            }
        }
    }
    
    func testInoutFuncInAllCombinations() throws {
        let replacer = NewlineReplacer()
        
        for newline in Newline.allCases {
            for originalNewline in Newline.allCases {
                var originalString = Self.testStringDictionary[originalNewline]!
                let testString = Self.testStringDictionary[newline]!
                
                replacer.replaceAll(in: &originalString, with: newline)
                
                XCTAssertEqual(originalString, testString)
            }
        }
    }
}

extension NewlineReplacerTests {

    static let crString = "acerola\rbanana\r\rcherry\r\rdragon fruit\r\rfig\r\rgrapefruit\r\rjujube kiwi\rlime\r\r\rmango   orange"

    static let lfString = "acerola\nbanana\n\ncherry\n\ndragon fruit\n\nfig\n\ngrapefruit\n\njujube kiwi\nlime\n\n\nmango   orange"
    
    static let crlfString = "acerola\r\nbanana\r\n\r\ncherry\r\n\r\ndragon fruit\r\n\r\nfig\r\n\r\ngrapefruit\r\n\r\njujube kiwi\r\nlime\r\n\r\n\r\nmango   orange"

    static let testStringDictionary: [Newline: String] = [
        .cr: crString,
        .lf: lfString,
        .crlf: crlfString
    ]
}
