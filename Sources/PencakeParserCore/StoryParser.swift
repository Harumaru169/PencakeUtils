//
//  StoryParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation

public class StoryParser<ArticleParserType: ArticleParserProtocol, StoryInfoParserType: StoryInfoParserProtocol>: StoryParserProtocol {
    private let articleParser: ArticleParserType
    private let storyInfoParser: StoryInfoParserType
    
    init(articleParser: ArticleParserType, storyInfoParser: StoryInfoParserType) {
        self.articleParser = articleParser
        self.storyInfoParser = storyInfoParser
    }
    
    public func parse(storyInfoData: Data, articleDatas: [Data], options: ParseOptions) async throws -> Story {
        var result: Story
        
        do {
            (result, _) = try await storyInfoParser.parse(from: storyInfoData)
        } catch {
            throw ParseError.failedToParseStoryInfo(error: error)
        }
        
        try await withThrowingTaskGroup(of: Article.self) { group in
            for articleData in articleDatas {
                group.addTask {
                    do {
                        return try await self.articleParser.parse(from: articleData, language: options.language)
                    } catch {
                        throw ParseError.failedToParseArticle(fileName: nil, error: error)
                    }
                }
            }
            
            for try await article in group {
                result.articles.append(article)
            }
        }
        
        return result
    }
    
    
    
    public func parse(directoryURL: URL, options: ParseOptions) async throws -> Story {
        let storyInfoFileURL = directoryURL
            .appendingPathComponent("Story")
            .appendingPathExtension("txt")
        
        guard let storyInfoData = FileManager.default.contents(atPath: storyInfoFileURL.path) else {
            throw ParseError.failedToReadFile(fileName: storyInfoFileURL.lastPathComponent)
        }
        
        var (result, articleCount): (Story, Int)
        
        do {
            (result, articleCount) = try await storyInfoParser.parse(from: storyInfoData)
        } catch {
            throw ParseError.failedToParseStoryInfo(error: error)
        }
        
        try await withThrowingTaskGroup(of: Article.self) { group in
            for index in 1...articleCount {
                _ = group.addTaskUnlessCancelled {
                    let articleFileName = "Article_" + String(format: "%03d", index)
                    let articleFileURL = directoryURL
                        .appendingPathComponent("Text")
                        .appendingPathComponent(articleFileName)
                        .appendingPathExtension("txt")
                    guard let articleData = FileManager.default.contents(atPath: articleFileURL.path) else {
                        throw ParseError.failedToReadFile(fileName: articleFileURL.lastPathComponent)
                    }
                    do {
                        return try await self.articleParser.parse(from: articleData, language: options.language)
                    } catch {
                        throw ParseError.failedToParseArticle(fileName: articleFileURL.lastPathComponent, error: error)
                    }
                }
            }
            
            for try await article in group {
                result.articles.append(article)
            }
        }
        
        return result
    }
    
}

extension StoryParser {
    public enum ParseError: Error, CustomStringConvertible {
        case failedToParseStoryInfo(error: Error)
        
        case failedToParseArticle(fileName: String?, error: Error)
        
        case failedToReadFile(fileName: String)
        
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
                    return "Failed to read \(fileName) file."
                case .unexpected(let error):
                    return "Unexpected error: \(error)"
            }
        }
    }
}

extension StoryParser where ArticleParserType == ArticleParser<NewlineCharacterReplacer>, StoryInfoParserType == StoryInfoParser {
    public convenience init() {
        self.init(articleParser: .init(), storyInfoParser: .init())
    }
}
