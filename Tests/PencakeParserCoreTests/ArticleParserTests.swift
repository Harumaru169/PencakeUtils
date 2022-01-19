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
    
    func testParsingJapaneseArticlesFromURL() async throws {
        XCTAssertEqual(Self.japaneseArticleStrings.count, Self.japaneseTestArticles.count)
        XCTAssertFalse(Self.japaneseArticleStrings.isEmpty)
        
        for (articleString, testArticle) in zip(Self.japaneseArticleStrings, Self.japaneseTestArticles) {
            let articleParser = ArticleParser()
            
            let fileURL = directoryURL!.appendingPathComponent("Article_\(UUID().uuidString).txt", isDirectory: false)
            let writingResult = FileManager.default.createFile(atPath: fileURL.path, contents: articleString.data(using: .utf8)!)
            
            guard writingResult == true else {
                XCTFail("Failed to write a file to the disk.")
                return
            }
            
            let article = try await articleParser.parse(fileURL: fileURL, language: .japanese)
            XCTAssertEqual(article, testArticle)
        }
    }
    
    func testParsingJapaneseArticlesFromData() async throws {
        XCTAssertEqual(Self.japaneseArticleStrings.count, Self.japaneseTestArticles.count)
        XCTAssertFalse(Self.japaneseArticleStrings.isEmpty)
        
        for (articleString, testArticle) in zip(Self.japaneseArticleStrings, Self.japaneseTestArticles) {
            let articleParser = ArticleParser()
            
            let articleData = articleString.data(using: .utf8)!
            
            let article = try await articleParser.parse(from: articleData, language: .japanese)
            
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
    
    static let japaneseArticleStrings = [
        "サンプル記事 No.1\n\n2022年1月19日(水) 16:29\n\n明日死ぬつもりで生きろ。永遠に生き続けるかのように学びなさい。\n- マハトマ・ガンジー",
        "サンプル記事 No.2\n\n2022年1月19日(水) 16:30\n\n天才とは、1パーセントのひらめきと99パーセントの汗である。\n- トーマス・アルヴァ・エジソン",
        "サンプル記事 No.3\n\n2022年1月19日(水) 16:30\n\n最も賢明な精神は、まだ学ぶべきことがある。\n- ジョージ・サンタヤーナ"
    ]
    
    static let japaneseTestArticles: [Article] = [
        .init(title: "サンプル記事 No.1", editDate: try! .init("2022-01-19T07:29:00Z", strategy: .iso8601), body: "明日死ぬつもりで生きろ。永遠に生き続けるかのように学びなさい。\n- マハトマ・ガンジー"),
        .init(title: "サンプル記事 No.2", editDate: try! .init("2022-01-19T07:30:00Z", strategy: .iso8601), body: "天才とは、1パーセントのひらめきと99パーセントの汗である。\n- トーマス・アルヴァ・エジソン"),
        .init(title: "サンプル記事 No.3", editDate: try! .init("2022-01-19T07:30:00Z", strategy: .iso8601), body: "最も賢明な精神は、まだ学ぶべきことがある。\n- ジョージ・サンタヤーナ")
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
