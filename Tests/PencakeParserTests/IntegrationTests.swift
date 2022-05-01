//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import XCTest
@testable import PencakeParser
import ZIPFoundation

class IntegrationTests: XCTestCase {
    let fileManager = FileManager.default
    
    func testParsingStoryWithPhotosFromDirectory() async throws {
        let directoryURL = fileManager.temporaryDirectory
            .appendingPathComponent("PencakeUtils_IntegrationTests_\(UUID().uuidString)", isDirectory: true)
        
        defer {
            try! fileManager.removeItem(at: directoryURL)
        }
        
        let story = try writeAndGenerateStory(destinationURL: directoryURL, includePhotos: true, inZipFormat: false)
        
        do {
            let storyParser = ParallelStoryParser()
            let parseOptions = ParseOptions(language: .japanese, newline: .lf)
            var parsedStory = try await storyParser.parse(directoryURL: directoryURL, options: parseOptions)
            parsedStory.articles.sort { $0.title < $1.title }
            
            XCTAssertEqual(parsedStory, story)
        } catch {
            XCTFail("Parse fail: \(error)")
        }
    }
    
    func testParsingStoryWithoutPhotosFromDirectory() async throws {
        let directoryURL = fileManager.temporaryDirectory
            .appendingPathComponent("PencakeUtils_IntegrationTests_\(UUID().uuidString)", isDirectory: true)
        
        defer {
            try! fileManager.removeItem(at: directoryURL)
        }
        
        let story = try writeAndGenerateStory(destinationURL: directoryURL, includePhotos: false, inZipFormat: false)
        
        do {
            let storyParser = ParallelStoryParser()
            let parseOptions = ParseOptions(language: .japanese, newline: .lf)
            var parsedStory = try await storyParser.parse(directoryURL: directoryURL, options: parseOptions)
            parsedStory.articles.sort { $0.title < $1.title }
            
            XCTAssertEqual(parsedStory, story)
        } catch {
            XCTFail("Parse fail: \(error)")
        }
    }
    
    func testParsingStoryWithPhotosFromZipFile() async throws {
        let zipFileURL = fileManager.temporaryDirectory
            .appendingPathComponent("PencakeUtils_IntegrationTests_\(UUID().uuidString).zip", isDirectory: false)
        
        defer {
            try! fileManager.removeItem(at: zipFileURL)
        }
        
        let story = try writeAndGenerateStory(destinationURL: zipFileURL, includePhotos: true, inZipFormat: true)
        
        do {
            let storyParser = ParallelStoryParser()
            let parseOptions = ParseOptions(language: .japanese, newline: .lf)
            var parsedStory = try await storyParser.parse(zipFileURL: zipFileURL, options: parseOptions)
            parsedStory.articles.sort { $0.title < $1.title }
            
            XCTAssertEqual(parsedStory, story)
        } catch {
            XCTFail("Parse fail: \(error)")
        }
    }
    
    func testParsingStoryWithoutPhotosFromZipFile() async throws {
        let zipFileURL = fileManager.temporaryDirectory
            .appendingPathComponent("PencakeUtils_IntegrationTests_\(UUID().uuidString).zip", isDirectory: false)
        
        defer {
            try! fileManager.removeItem(at: zipFileURL)
        }
        
        let story = try writeAndGenerateStory(destinationURL: zipFileURL, includePhotos: false, inZipFormat: true)
        
        do {
            let storyParser = ParallelStoryParser()
            let parseOptions = ParseOptions(language: .japanese, newline: .lf)
            var parsedStory = try await storyParser.parse(zipFileURL: zipFileURL, options: parseOptions)
            parsedStory.articles.sort { $0.title < $1.title }
            
            XCTAssertEqual(parsedStory, story)
        } catch {
            XCTFail("Parse fail: \(error)")
        }
    }
}

extension IntegrationTests {
    func writeAndGenerateStory(destinationURL: URL, includePhotos: Bool, inZipFormat: Bool) throws -> Story{
        let storyDirectoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
        
        storyDirectoryWrapper.addRegularFile(withContents: Constants.storyInfoData, preferredFilename: "Story.txt")
        
        let textDirectoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
        textDirectoryWrapper.preferredFilename = "Text"
        for (fileName, content) in Constants.articleDictionary {
            textDirectoryWrapper.addRegularFile(withContents: content, preferredFilename: fileName)
        }
        storyDirectoryWrapper.addFileWrapper(textDirectoryWrapper)
        
        var articles = Constants.articles
        
        if includePhotos {
            let photosDirectoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
            photosDirectoryWrapper.preferredFilename = "Photos"
            let photoFileNames = ["IMG_001_001.png", "IMG_002_001.png", "IMG_003_001.png"]
            for photoFileName in photoFileNames {
                photosDirectoryWrapper.addRegularFile(withContents: Constants.photoData, preferredFilename: photoFileName)
            }
            storyDirectoryWrapper.addFileWrapper(photosDirectoryWrapper)
            for index in photoFileNames.indices {
                articles[index].photos = [Constants.photo]
            }
        }
        
        if inZipFormat {
            let tempDirectoryURL = fileManager.temporaryDirectory
                .appendingPathComponent("PencakeUtils_IntegrationTests_\(UUID().uuidString)", isDirectory: true)
            
            defer {
                try! fileManager.removeItem(at: tempDirectoryURL)
            }
            
            try storyDirectoryWrapper.write(to: tempDirectoryURL, originalContentsURL: nil)
            
            let archive = Archive(accessMode: .create)!
            for subpath in try fileManager.subpathsOfDirectory(atPath: tempDirectoryURL.path) {
                try archive.addEntry(with: subpath, relativeTo: tempDirectoryURL)
            }
            let writingResult = fileManager.createFile(atPath: destinationURL.path, contents: archive.data, attributes: nil)
            guard writingResult == true else { fatalError() }
            
            return .init(information: Constants.storyInfo, articles: articles)
        } else {
            try storyDirectoryWrapper.write(to: destinationURL, originalContentsURL: nil)
            return .init(information: Constants.storyInfo, articles: articles)
        }
    }
}

extension IntegrationTests {
    enum Constants {
        static var storyInfo: StoryInformation {
            .init(
                title: "Sample Story",
                subtitle: "Quotes from the greats.",
                createdDate: .init(timeIntervalSince1970: 1641488677.0),
                exportedDate: .init(timeIntervalSince1970: 1647331018.0),
                articleCount: 3
            )
        }
        
        static var storyInfoData: Data {
            "# Title\r\nSample Story\r\n\r\n# Subtitle\r\nQuotes from the greats.\r\n\r\n# Created at\r\n2022/1/7 2:04:37\r\n\r\n# Exported at\r\n2022/3/15 16:56:58\r\n\r\n# Article count\r\n3\r\n\r\n# Articles\r\n001 - Sample Article No.1\r\n002 - Sample Article No.2\r\n003 - Sample Article No.3\r\n"
                .data(using: .utf8)!
        }
        
        static var articleDictionary: [(String, Data)] {
            [
                ("Article_001.txt", "Sample Article No.1\r\n\r\n2022年1月7日(金) 02:07\r\n\r\nLive as if you were to die tomorrow. Learn as if you were to live forever.\r\n- Mahatma Gandhi"),
                ("Article_002.txt", "Sample Article No.2\r\n\r\n2022年1月7日(金) 02:08\r\n\r\nGenius is 1 percent inspiration and 99 percent perspiration.\r\n- Thomas Alva Edison"),
                ("Article_003.txt", "Sample Article No.3\r\n\r\n2022年1月7日(金) 02:09\r\n\r\nThe wisest mind has something yet to learn.\r\n- George Santayana")
            ].map { (fileName, content) in
                (fileName, content.data(using: .utf8)!)
            }
        }
        
        static var articles: [Article] {
            [
                .init(title: "Sample Article No.1", editDate: .init(timeIntervalSince1970: 1641488820.0), body: "Live as if you were to die tomorrow. Learn as if you were to live forever.\n- Mahatma Gandhi"),
                .init(title: "Sample Article No.2", editDate: .init(timeIntervalSince1970: 1641488880.0), body: "Genius is 1 percent inspiration and 99 percent perspiration.\n- Thomas Alva Edison"),
                .init(title: "Sample Article No.3", editDate: .init(timeIntervalSince1970: 1641488940.0), body: "The wisest mind has something yet to learn.\n- George Santayana")
            ]
        }
        
        static var photoData: Data {
            let base64EncodedString = "iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAABKADAAQAAAABAAAABAAAAADFbP4CAAAAHGlET1QAAAACAAAAAAAAAAIAAAAoAAAAAgAAAAIAAABiGLtcQAAAAC5JREFUGBkAIgDd/wA7Y7PQV3u49GBXsvdWcbfjAEZKov9LfLH+Snaw/0Jcqv0AAAD//1lyDKoAAAArSURBVAEiAN3/ADxqs+5IaK79MFu3/ytRqvMAT3ix80NQptxDcbn4Nkef+dueJLJIY+QyAAAAAElFTkSuQmCC"
            return Data(base64Encoded: base64EncodedString)!
        }
        
        static var photo: Photo = .init(data: photoData, fileExtension: "png", isTrimmedCoverPhoto: false)
    }
}
