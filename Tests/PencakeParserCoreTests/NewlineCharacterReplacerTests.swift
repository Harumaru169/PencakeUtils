//
//  NewlineCharacterReplacerTests.swift
//  
//
//  Created by k.haruyama on 2022/01/28.
//  
//

import XCTest
import PencakeParserCore

class NewlineCharacterReplacerTests: XCTestCase {

    func testFuncInAllCombinations() throws {
        let replacer = NewlineCharacterReplacer()
        
        for newlineChar in NewlineCharacter.allCases {
            for originalNewlineChar in NewlineCharacter.allCases {

                let originalString = Self.testStringDictionary[originalNewlineChar]!
                let testString = Self.testStringDictionary[newlineChar]!
                
                let result = replacer.replacingAll(in: originalString, with: newlineChar)
                
                XCTAssertEqual(result, testString)
            }
        }
    }
    
    func testInoutFuncInAllCombinations() throws {
        let replacer = NewlineCharacterReplacer()
        
        for newlineChar in NewlineCharacter.allCases {
            for originalNewlineChar in NewlineCharacter.allCases {
                var originalString = Self.testStringDictionary[originalNewlineChar]!
                let testString = Self.testStringDictionary[newlineChar]!
                
                replacer.replaceAll(in: &originalString, with: newlineChar)
                
                XCTAssertEqual(originalString, testString)
            }
        }
    }
}

extension NewlineCharacterReplacerTests {

    static let crString = "acerola\rbanana\r\rcherry\r\rdragon fruit\r\rfig\r\rgrapefruit\r\rjujube kiwi\rlime\r\r\rmango   orange"

    static let lfString = "acerola\nbanana\n\ncherry\n\ndragon fruit\n\nfig\n\ngrapefruit\n\njujube kiwi\nlime\n\n\nmango   orange"
    
    static let crlfString = "acerola\r\nbanana\r\n\r\ncherry\r\n\r\ndragon fruit\r\n\r\nfig\r\n\r\ngrapefruit\r\n\r\njujube kiwi\r\nlime\r\n\r\n\r\nmango   orange"

    static let testStringDictionary: [NewlineCharacter: String] = [
        .cr: crString,
        .lf: lfString,
        .crlf: crlfString
    ]
}
