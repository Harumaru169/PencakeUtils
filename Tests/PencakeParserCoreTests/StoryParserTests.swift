//
//  StoryParserTests.swift
//  
//
//  Created by k.haruyama on 2022/01/19.
//  
//

import XCTest
@testable import PencakeParserCore

class StoryParserTests: XCTestCase {
    var directoryURL: URL?
    
    override func setUp() async throws {
        directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("PencakeParser.StoryParserTests", isDirectory: true)
        if FileManager.default.fileExists(atPath: directoryURL!.path) {
            try FileManager.default.removeItem(at: directoryURL!)
        }
        try FileManager.default.createDirectory(atPath: directoryURL!.path, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        try FileManager.default.removeItem(at: directoryURL!)
    }
    
    func testParsingFromURL() async throws {
        let storyParser = StoryParser(
            articleParser: ArticleParserMock(),
            storyInfoParser: StoryInfoParserMock()
        )
        
        let storyURL = directoryURL!.appendingPathComponent("MockStory", isDirectory: true)
        
        try Constants.storyFileWrapper.write(to: storyURL, originalContentsURL: nil)
        
        let story = try await storyParser.parse(directoryURL: storyURL, language: .english)
        XCTAssertEqual(story, Constants.story)
    }
    
    func testParsingFromData() async throws {
        let storyParser = StoryParser(
            articleParser: ArticleParserMock(),
            storyInfoParser: StoryInfoParserMock()
        )
        
        let story = try await storyParser.parse(storyInfoData: Constants.data, articleDatas: Constants.dataArray, language: .english)
        
        XCTAssertEqual(story, Constants.story)
    }
}

extension StoryParserTests {
    class StoryInfoParserMock: StoryInfoParserProtocol {
        func parse(from: Data) async throws -> (Story, articleCount: Int) {
            return Constants.storyInfo
        }
        
        func parse(fileURL: URL) async throws -> (Story, articleCount: Int) {
            return Constants.storyInfo
        }
    }
    
    class ArticleParserMock: ArticleParserProtocol {
        func parse(from: Data, language: Language) async throws -> Article {
            return Constants.article
        }
        
        func parse(fileURL: URL, language: Language) async throws -> Article {
            return Constants.article
        }
    }
}

extension StoryParserTests {
    enum Constants {
        static let date = Date(timeIntervalSince1970: 0)
        
        static let data = "".data(using: .utf8)!
        
        static let dataArray = Array(repeating: data, count: 3)
        
        static let article = Article(title: "title", editDate: date, body: "body")
        
        static let articles = Array(repeating: article, count: 3)
        
        static let storyInfo: (Story, articleCount: Int) = (
            Story(title: "title", subtitle: "subtitle", createdDate: date, exportedDate: date, articles: []),
            3
        )
        
        static let story: Story = .init(
            title: "title",
            subtitle: "subtitle",
            createdDate: date,
            exportedDate: date,
            articles: articles
        )
        
        static let storyFileWrapper: FileWrapper = {
            let textDirectory = FileWrapper(directoryWithFileWrappers: [:])
            
            let storyDirectory = FileWrapper(directoryWithFileWrappers: [
                "Story.txt": .init(regularFileWithContents: data),
                "Text": textDirectory
            ])
            
            for index in 1...3 {
                let fileName = "Article_\(String(format: "%03d", index)).txt"
                textDirectory.addRegularFile(withContents: data, preferredFilename: fileName)
            }
            return storyDirectory
        }()
    }
}
