// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import XCTest
@testable import PencakeParser

class StoryInfoParserTests: XCTestCase {
    var directoryURL: URL?
    
    override func setUp() async throws {
        directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("PencakeParser.StoryInfoParserTests", isDirectory: true)
        if FileManager.default.fileExists(atPath: directoryURL!.path) {
            try FileManager.default.removeItem(at: directoryURL!)
        }
        try FileManager.default.createDirectory(at: directoryURL!, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        try FileManager.default.removeItem(at: directoryURL!)
    }
    
    func testParsingFromURL() async throws {
        let storyInfoParser = StoryInfoParser()
        
        let fileURL = directoryURL!.appendingPathComponent("Story.txt", isDirectory: false)
        let writingResult = FileManager.default.createFile(atPath: fileURL.path, contents: Self.storyInfoString.data(using: .utf8))
        
        XCTAssertTrue(writingResult, "Failed to write a file to the disk")
        
        let storyInfo = try await storyInfoParser.parse(fileURL: fileURL)
        
        XCTAssertEqual(storyInfo, Self.testStoryInfo)
        XCTAssertEqual(storyInfo.articleCount, Self.testStoryInfo.articleCount)
    }
    
    func testParsingFromData() async throws {
        let storyInfoParser = StoryInfoParser()
        
        let storyInfoData = Self.storyInfoString.data(using: .utf8)!
        
        let storyInfo = try await storyInfoParser.parse(from: storyInfoData)
        
        XCTAssertEqual(storyInfo, Self.testStoryInfo)
        XCTAssertEqual(storyInfo.articleCount, Self.testStoryInfo.articleCount)
    }
}

extension StoryInfoParserTests {
    static let storyInfoString = "# Title\nサンプルストーリー\n\n# Subtitle\n偉人たちの名言\n\n# Created at\n2022/1/19 16:28:10\n\n# Exported at\n2022/1/19 16:44:27\n\n# Article count\n3\n\n# Articles\n001 - サンプル記事 No.1\n002 - サンプル記事 No.2\n003 - サンプル記事 No.3\n"
    
    static let testStoryInfo: StoryInformation = .init(title: "サンプルストーリー", subtitle: "偉人たちの名言", createdDate: try! .init("2022-01-19T07:28:10Z", strategy: .iso8601), exportedDate: try! .init("2022-01-19T07:44:27Z", strategy: .iso8601), articleCount: 3)
}
