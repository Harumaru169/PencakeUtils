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

    func testParsingEnglishArticles() async throws {
        let articleURLs = Bundle.module.urls(forResourcesWithExtension: "txt", subdirectory: "EnSampleStory")!
        
        let testArticleURLs = Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: "ParsedEnSampleStory")!
        
        for (articleURL, testArticleURL) in zip(articleURLs, testArticleURLs) {
            let articleData = FileManager.default.contents(atPath: articleURL.path)!
            let article = try await ArticleParser.shared.parse(from: articleData, language: .english)
            
            let testArticleData = FileManager.default.contents(atPath: testArticleURL.path)!
            let testArticle = try JSONDecoder().decode(Article.self, from: testArticleData)
            
            XCTAssertEqual(article, testArticle)
        }
    }

}
