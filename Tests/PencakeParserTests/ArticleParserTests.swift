//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import XCTest
import SampleGenerator
@testable import PencakeParser

class ArticleParserTests: XCTestCase {
    var directoryURL: URL?
    
    override func setUp() async throws {
        directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("PencakeParser.ArticleParserTests", isDirectory: true)
        if FileManager.default.fileExists(atPath: directoryURL!.path) {
            try FileManager.default.removeItem(at: directoryURL!)
        }
        try FileManager.default.createDirectory(atPath: directoryURL!.path, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        try FileManager.default.removeItem(at: directoryURL!)
    }
    
    func testParsingFromURL() async throws {
        let articleNumberRange = 1...(Int.random(in: 3...10))
        let articleParser = ArticleParser()
        
        for (number, generateOptions) in product(articleNumberRange, GenerateOptions.allCases) {
            let (article, file) = SampleArticleGenerator.default.generateArticleAndFileWrapper(number: number, options: generateOptions)
            let fileURL = directoryURL!.appendingPathComponent("Article_\(String(format: "%03d", number))_\(UUID().uuidString).txt", isDirectory: false)
            try file.write(to: fileURL, options: .atomic, originalContentsURL: nil)
            
            do {
                let parseOptions = ParseOptions(language: generateOptions.language, newline: generateOptions.newline)
                let parsedArticle = try await articleParser.parse(fileURL: fileURL, options: parseOptions)
                
                XCTAssertEqual(article, parsedArticle)
            } catch {
                XCTFail("Failed to parse article: \(error)")
            }
        }
    }
    
    func testParsingFromData() async throws {
        let articleNumberRange = 1...(Int.random(in: 3...10))
        let articleParser = ArticleParser()
        
        for (number, generateOptions) in product(articleNumberRange, GenerateOptions.allCases) {
            let (article, data) = SampleArticleGenerator.default.generateArticleAndData(number: number, options: generateOptions)
            
            do {
                let parseOptions = ParseOptions(language: generateOptions.language, newline: generateOptions.newline)
                let parsedArticle = try await articleParser.parse(from: data, options: parseOptions)
                
                XCTAssertEqual(article, parsedArticle)
            } catch {
                XCTFail("Failed to parse article: \(error)")
            }
        }
    }
}
