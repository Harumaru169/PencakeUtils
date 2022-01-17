//
//  StoryParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation
import Regex

public class StoryParser {
    private init() {}
    
    public static let shared: StoryParser = .init()
    
    private static let articleParser = ArticleParser.shared
    
    func parse(
        storyInfoData: Data,
        articleDatas: [Data],
        language: Language = .english
    ) async throws -> Story {
        //MARK: analyzing story info data
        var (result, _) = try await StoryInfoParser.shared.parse(from: storyInfoData)
        
        //MARK: parsing articles data using ArticleParser
        do {
            
            try await withThrowingTaskGroup(of: Article.self) { group in
                
                for articleData in articleDatas {
                    group.addTask {
                        return try await Self.articleParser.parse(from: articleData, language: language)
                    }
                }
                
                for try await article in group {
                    result.articles.append(article)
                }
            }
            
        } catch {
            throw StoryParsingError("なんかダメだったぽいね。", underlyingError: error)
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
            throw StoryParsingError("Story.txtファイル読むの失敗したね。")
        }
        
        var (result, articleCount) = try await StoryInfoParser.shared.parse(from: storyInfoData)
        
        try await withThrowingTaskGroup(of: Article.self) { group in
            for index in 1...articleCount {
                _ = group.addTaskUnlessCancelled {
                    let articleFileName = "Article_" + String(format: "%03d", index)
                    let articleFileURL = directoryURL
                        .appendingPathComponent("Text")
                        .appendingPathComponent(articleFileName)
                        .appendingPathExtension("txt")
                    guard let articleData = FileManager.default.contents(atPath: articleFileURL.path) else {
                        throw StoryParsingError("\(articleFileURL.lastPathComponent)読むのに失敗したね。")
                    }
                    return try await Self.articleParser.parse(from: articleData, language: language)
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
    struct StoryParsingError: Error, CustomStringConvertible {
        var description: String
        
        var underlyingError: Error?
        
        init(_ description: String, underlyingError: Error? = nil) {
            self.description = description
            self.underlyingError = underlyingError
        }
    }
}
