//
//  ArticleParserTests.swift
//  
//
//  Created by k.haruyama on 2022/01/07.
//  
//

import XCTest
import PencakeParserCore

class ArticleParserTests: XCTestCase {
    var directoryURL: URL?
    
    override func setUp() async throws {
        directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("ArticleParserTests", isDirectory: true)
        guard FileManager.default.fileExists(atPath: directoryURL!.path) == false else {
            throw PreparationError("The directory generated in the previous test is still on the disk.")
        }
        try FileManager.default.createDirectory(atPath: directoryURL!.path, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        try FileManager.default.removeItem(at: directoryURL!)
    }
    
    func testParsingEnglishArticlesFromURL() async throws {
        XCTAssertEqual(Self.englishArticleStrings.count, Self.englishTestArticles.count)
        XCTAssertFalse(Self.englishArticleStrings.isEmpty)
        
        for (articleString, testArticle) in zip(Self.englishArticleStrings, Self.englishTestArticles) {
            let articleParser = ArticleParser()
            
            let fileURL = directoryURL!.appendingPathComponent("Article_\(UUID().uuidString).txt", isDirectory: false)
            let writingResult = FileManager.default.createFile(atPath: fileURL.path, contents: articleString.data(using: .utf8)!)
            
            guard writingResult == true else {
                XCTFail("Failed to write a file to the disk.")
                return
            }
            
            let article = try await articleParser.parse(fileURL: fileURL, language: .english)
            XCTAssertEqual(article, testArticle)
        }
    }
    
    func testParsingEnglishArticlesFromData() async throws {
        XCTAssertEqual(Self.englishArticleStrings.count, Self.englishTestArticles.count)
        XCTAssertFalse(Self.englishArticleStrings.isEmpty)
        
        for (articleString, testArticle) in zip(Self.englishArticleStrings, Self.englishTestArticles) {
            let articleParser = ArticleParser()
            
            let articleData = articleString.data(using: .utf8)!
            
            let article = try await articleParser.parse(from: articleData, language: .english)
            
            XCTAssertEqual(article, testArticle)
        }
    }
}

extension ArticleParserTests {
    static let englishArticleStrings = [
        "Sample Article No.1\n\nFri, Jan 7, 2022 2:07 AM\n\nLive as if you were to die tomorrow. Learn as if you were to live forever.\n- Mahatma Gandhi",
        "Sample Article No.2\n\nFri, Jan 7, 2022 2:08 AM\n\nGenius is 1 percent inspiration and 99 percent perspiration.\n- Thomas Alva Edison",
        "Sample Article No.3\n\nFri, Jan 7, 2022 2:09 AM\n\nThe wisest mind has something yet to learn.\n- George Santayana"
    ]
    
    static let englishTestArticles: [Article] = [
        .init(title: "Sample Article No.1", editDate: try! .init("2022-01-06T17:07:00Z", strategy: .iso8601), body: "Live as if you were to die tomorrow. Learn as if you were to live forever.\n- Mahatma Gandhi"),
        .init(title: "Sample Article No.2", editDate: try! .init("2022-01-06T17:08:00Z", strategy: .iso8601), body: "Genius is 1 percent inspiration and 99 percent perspiration.\n- Thomas Alva Edison"),
        .init(title: "Sample Article No.3", editDate: try! .init("2022-01-06T17:09:00Z", strategy: .iso8601), body: "The wisest mind has something yet to learn.\n- George Santayana")
    ]
}

extension ArticleParserTests {
    struct PreparationError: Error, CustomStringConvertible {
        var description: String
        
        init(_ description: String) {
            self.description = description
        }
    }
}
