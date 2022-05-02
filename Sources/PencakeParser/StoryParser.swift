//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import ZIPFoundation

public final class StoryParser<
    ArticleParserType: ArticleParserProtocol,
    StoryInfoParserType: StoryInfoParserProtocol,
    PhotosLoaderType: PhotosLoaderProtocol
>: StoryParserProtocol {
    private let articleParser: ArticleParserType
    private let storyInfoParser: StoryInfoParserType
    private let photosLoader: PhotosLoaderType
    
    init(articleParser: ArticleParserType, storyInfoParser: StoryInfoParserType, photosLoader: PhotosLoaderType) {
        self.articleParser = articleParser
        self.storyInfoParser = storyInfoParser
        self.photosLoader = photosLoader
    }
    
    public func parse(directoryURL: URL, options: ParseOptions) throws -> Story {
        let fileManager = FileManager.default
        
        let fileType = try fileManager.type(at: directoryURL)
        guard fileType == .typeDirectory else {
            throw ParseError.unexpectedFileType(path: directoryURL.path, expected: .typeDirectory, actual: fileType)
        }
        
        let storyInfoFileURL = directoryURL
            .appendingPathComponent("Story")
            .appendingPathExtension("txt")
        
        var information: StoryInformation
        
        do {
            information = try storyInfoParser.parse(fileURL: storyInfoFileURL)
        } catch {
            throw ParseError.failedToParseStoryInfo(error: error)
        }
        
        let photosDirectoryURL = directoryURL.appendingPathComponent("Photos", isDirectory: true)
        let photosDirectoryExists = fileManager.fileExists(atPath: photosDirectoryURL.path)
        
        let articles: [Article] = try (1...information.articleCount).map { index throws -> Article in
            let articleFileName = "Article_" + String(format: "%03d", index)
            
            let articleFileURL = directoryURL
                .appendingPathComponent("Text")
                .appendingPathComponent(articleFileName)
                .appendingPathExtension("txt")
            
            guard fileManager.fileExists(atPath: articleFileURL.path) else {
                throw ParseError.fileDoesNotExist(path: articleFileURL.path)
            }
            
            guard let articleData = fileManager.contents(atPath: articleFileURL.path) else {
                throw ParseError.failedToReadFile(path: articleFileURL.path)
            }
            
            do {
                var article = try self.articleParser.parse(from: articleData, options: options)
                if photosDirectoryExists {
                    article.photos = try self.photosLoader.load(from: photosDirectoryURL, articleNumber: index)
                }
                return article
            } catch {
                throw ParseError.failedToParseArticle(path: articleFileURL.path, error: error)
            }
        }
        
        guard information.articleCount == articles.count else { fatalError("Inconsistent article count") }
        
        return Story(information: information, articles: articles)
    }
    
    
    public func parse(zipFileURL: URL, options: ParseOptions) throws -> Story {
        let fileManager = FileManager.default
        
        let fileType = try fileManager.type(at: zipFileURL)
        guard fileType == .typeRegular else {
            throw ParseError.unexpectedFileType(path: zipFileURL.path, expected: .typeRegular, actual: fileType)
        }
        
        let directoryURL = fileManager.temporaryDirectory.appendingPathComponent("PencakeParser-StoryParser-temp", isDirectory: true)
        if fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.removeItem(at: directoryURL)
        }
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        defer {
            do {
                try fileManager.removeItem(at: directoryURL)
            } catch {
                fatalError("Failed to remove temporary directory")
            }
        }
        
        do {
            try fileManager.unzipItem(at: zipFileURL, to: directoryURL)
        } catch {
            throw ParseError.failedToExtractZipFile(error: error)
        }
        
        return try parse(directoryURL: directoryURL, options: options)
    }
}

extension StoryParser where ArticleParserType == ArticleParser<NewlineReplacer>,
                            StoryInfoParserType == StoryInfoParser,
                            PhotosLoaderType == PhotosLoader {
    public convenience init() {
        self.init(articleParser: .init(), storyInfoParser: .init(), photosLoader: .init())
    }
}
