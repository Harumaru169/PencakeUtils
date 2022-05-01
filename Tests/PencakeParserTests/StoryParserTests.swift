//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import XCTest
@testable import PencakeParser
import ZIPFoundation

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
            storyInfoParser: StoryInfoParserMock(),
            photosLoader: PhotosLoaderMock()
        )

        let storyURL = directoryURL!.appendingPathComponent("MockStory", isDirectory: true)
        
        try Constants.storyFileWrapper.write(to: storyURL, originalContentsURL: nil)
        
        let parseOptions = ParseOptions(language: .english)
        let story = try await storyParser.parse(directoryURL: storyURL, options: parseOptions)
        XCTAssertEqual(story, Constants.story)
    }
    
    func testParsingFromZipFile() async throws {
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent("PencakeParser_StoryParserTests_PreCompressedDirectory", isDirectory: true)
        let zipFileURL = fileManager.temporaryDirectory.appendingPathComponent("PencakeParser_StoryParserTests_ZipFile.zip", isDirectory: false)
        
        defer {
            do {
                try fileManager.removeItem(at: tempDirectoryURL)
                try fileManager.removeItem(at: zipFileURL)
            } catch {
                XCTFail("Failed to remove temporary files and directories")
            }
        }
        
        do {
            try Constants.storyFileWrapper.write(to: tempDirectoryURL, originalContentsURL: nil)
        } catch {
            XCTFail("File preparation fail: \(error)")
        }
        
        do {
            let archive = Archive(accessMode: .create)!
            for subpath in try fileManager.subpathsOfDirectory(atPath: tempDirectoryURL.path) {
                try archive.addEntry(with: subpath, relativeTo: tempDirectoryURL)
            }
            let result = fileManager.createFile(atPath: zipFileURL.path, contents: archive.data, attributes: nil)
            guard result == true else { fatalError() }
        } catch {
            XCTFail("Archive fail: \(error)")
        }
        
        do {
            let storyParser = StoryParser(
                articleParser: ArticleParserMock(),
                storyInfoParser: StoryInfoParserMock(),
                photosLoader: PhotosLoaderMock()
            )
            let parseOptions = ParseOptions(language: .english)
            let story = try await storyParser.parse(zipFileURL: zipFileURL, options: parseOptions)
            
            XCTAssertEqual(story, Constants.story)
        } catch {
            XCTFail("Parse fail: \(error)")
        }
    }
}

extension StoryParserTests {
    final class StoryInfoParserMock: StoryInfoParserProtocol {
        func parse(from: Data) throws -> StoryInformation {
            return Constants.storyInfo
        }
        
        func parse(fileURL: URL) throws -> StoryInformation {
            return Constants.storyInfo
        }
    }
    
    final class ArticleParserMock: ArticleParserProtocol {
        func parse(from: Data, options: ParseOptions) throws -> Article {
            return Constants.article
        }
        
        func parse(fileURL: URL, options: ParseOptions) throws -> Article {
            return Constants.article
        }
    }
    
    final class PhotosLoaderMock: PhotosLoaderProtocol {
        func load(from: URL, articleNumber: Int?) async throws -> [Photo] {
            return []
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
        
        static let storyInfo: StoryInformation = .init(title: "title", subtitle: "subtitle", createdDate: date, exportedDate: date, articleCount: 3)
        
        static let story: Story = .init(
            title: "title",
            subtitle: "subtitle",
            createdDate: date,
            exportedDate: date,
            articles: articles
        )
        
        static let storyFileWrapper: FileWrapper = {
            let textDirectory = FileWrapper(directoryWithFileWrappers: [:])
            
            let photosDirectory = FileWrapper(directoryWithFileWrappers: [:])
            
            let storyDirectory = FileWrapper(directoryWithFileWrappers: [
                "Story.txt": .init(regularFileWithContents: data),
                "Text": textDirectory,
                "Photos": photosDirectory
            ])
            
            for index in 1...3 {
                let fileName = "Article_\(String(format: "%03d", index)).txt"
                textDirectory.addRegularFile(withContents: data, preferredFilename: fileName)
            }
            return storyDirectory
        }()
    }
}
