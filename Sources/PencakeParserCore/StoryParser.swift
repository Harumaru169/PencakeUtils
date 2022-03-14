//
//  StoryParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation
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
    
    public func parse(directoryURL: URL, options: ParseOptions) async throws -> Story {
        let storyInfoFileURL = directoryURL
            .appendingPathComponent("Story")
            .appendingPathExtension("txt")
        
        guard let storyInfoData = FileManager.default.contents(atPath: storyInfoFileURL.path) else {
            throw ParseError.failedToReadFile(fileName: storyInfoFileURL.lastPathComponent)
        }
        
        var information: StoryInformation
        var articles: [Article] = []
        
        do {
            information = try await storyInfoParser.parse(from: storyInfoData)
        } catch {
            throw ParseError.failedToParseStoryInfo(error: error)
        }
        
        let photosDirectoryURL = directoryURL.appendingPathComponent("Photos", isDirectory: true)
        
        try await withThrowingTaskGroup(of: Article.self) { group in
            for index in 1...information.articleCount {
                _ = group.addTaskUnlessCancelled { [self] in
                    let articleFileName = "Article_" + String(format: "%03d", index)
                    
                    let articleFileURL = directoryURL
                        .appendingPathComponent("Text")
                        .appendingPathComponent(articleFileName)
                        .appendingPathExtension("txt")
                    
                    guard FileManager.default.fileExists(atPath: articleFileURL.path) else {
                        throw ParseError.fileDoesNotExist(fileName: articleFileURL.lastPathComponent)
                    }
                    
                    guard let articleData = FileManager.default.contents(atPath: articleFileURL.path) else {
                        throw ParseError.failedToReadFile(fileName: articleFileURL.lastPathComponent)
                    }
                    
                    do {
                        var article = try await self.articleParser.parse(from: articleData, options: options)
                        article.photos = try await self.photosLoader.load(from: photosDirectoryURL, articleNumber: index)
                        return article
                    } catch {
                        throw ParseError.failedToParseArticle(fileName: articleFileURL.lastPathComponent, error: error)
                    }
                }
            }
            
            for try await article in group {
                articles.append(article)
            }
        }
        
        guard information.articleCount == articles.count else { fatalError("Inconsistent article count") }
        
        return Story(information: information, articles: articles)
    }
    
    
    public func parse(zipFileURL: URL, options: ParseOptions) async throws -> Story {
        let fileManager = FileManager.default
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
        
        return try await parse(directoryURL: directoryURL, options: options)
    }
}

extension StoryParser {
    public enum ParseError: Error, CustomStringConvertible {
        case failedToParseStoryInfo(error: Error)
        
        case failedToParseArticle(fileName: String?, error: Error)
        
        case failedToReadFile(fileName: String)
        
        case fileDoesNotExist(fileName: String)
        
        case failedToExtractZipFile(error: Error)
        
        case unexpected(error: Error)
        
        public var description: String {
            switch self {
                case .failedToParseStoryInfo(let error):
                    return "Failed to parse story info: \(error)"
                case .failedToParseArticle(let fileName, let error):
                    if let fileName = fileName {
                        return "Failed to parse \(fileName): \(error)"
                    } else {
                        return "Failed to parse article: \(error)"
                    }
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName) file"
                case .fileDoesNotExist(let fileName):
                    return "\(fileName) does not exist"
                case .failedToExtractZipFile(let error):
                    return "Failed to extract ZIP file: \(error)"
                case .unexpected(let error):
                    return "Unexpected error: \(error)"
            }
        }
    }
}

extension StoryParser where ArticleParserType == ArticleParser<NewlineReplacer>,
                            StoryInfoParserType == StoryInfoParser,
                            PhotosLoaderType == PhotosLoader {
    public convenience init() {
        self.init(articleParser: .init(), storyInfoParser: .init(), photosLoader: .init())
    }
}
