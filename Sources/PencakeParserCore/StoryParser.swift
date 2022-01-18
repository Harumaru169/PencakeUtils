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
    
    public init(articleParser: ArticleParserType, storyInfoParser: StoryInfoParserType) {
        self.articleParser = articleParser
        self.storyInfoParser = storyInfoParser
    }
    
    public func parse(
        storyInfoData: Data,
        articleDatas: [Data],
        language: Language = .english
    ) async throws -> Story {
        //MARK: analyzing story info data
        var (result, _) = try await storyInfoParser.parse(from: storyInfoData)
        
        //MARK: parsing articles data using ArticleParser
        do {
            
            try await withThrowingTaskGroup(of: Article.self) { group in
                
                for articleData in articleDatas {
                    group.addTask {
                        return try await self.articleParser.parse(from: articleData, language: language)
                    }
                }
                
                for try await article in group {
                    result.articles.append(article)
                }
            }
            
        } catch let error as ArticleParser.ParseError {
            throw ParseError.failedToParseArticle(error: error)
        } catch {
            throw ParseError.unexpected(error: error)
        }
        
        return result
    }
    
    
    
    public func parse(
        directoryURL: URL,
        language: Language = .english
    ) async throws -> Story {
        let storyInfoFileURL = directoryURL
            .appendingPathComponent("Story")
            .appendingPathExtension("txt")
        
        guard let storyInfoData = FileManager.default.contents(atPath: storyInfoFileURL.path) else {
            throw ParseError.failedToReadFile(fileName: storyInfoFileURL.lastPathComponent)
        }
        
        var (result, articleCount) = try await storyInfoParser.parse(from: storyInfoData)
        
        do {
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
                        return try await self.articleParser.parse(from: articleData, language: language)
                    }
                }
                
                for try await article in group {
                    result.articles.append(article)
                }
            }
        } catch let error as ArticleParser.ParseError {
            throw ParseError.failedToParseArticle(error: error)
        } catch {
            throw ParseError.unexpected(error: error)
        }
        
        return result
    }
    
}

extension StoryParser {
    public enum ParseError: Error, CustomStringConvertible {
        
        case failedToParseArticle(error: ArticleParser.ParseError)
        
        case failedToReadFile(fileName: String)
        
        case unexpected(error: Error)
        
        public var description: String {
            switch self {
                case .failedToParseArticle(let error):
                    return "Failed to parse article: \(error)"
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName) file."
                case .unexpected(let error):
                    return "Unexpected error: \(error)"
            }
        }
    }
}
