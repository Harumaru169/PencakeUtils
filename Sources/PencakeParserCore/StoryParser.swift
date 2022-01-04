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
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return df
    }()
    
    private static let articleParser = ArticleParser.shared
    
    private static let regex = try! Regex(
        pattern: "# Title(\n|\r\n)(.*)\\1{2}# Subtitle\\1(.*)\\1{2}# Created at\\1(.*)\\1{2}# Exported at\\1(.*)\\1{2}# Article count\\1([0-9]*)\\1{2}# Articles\\1([\\s\\S]*)\\1",
        groupNames: "lineBreak", "title", "subtitle", "createdAt", "exportedAt", "articleCount", "articles"
    )
    
    func parse(storyInfoData: Data, articleDatas: [Data]) async throws -> Story {
        //MARK: analyzing story info data
        var (result, _) = try parseStoryInfo(from: storyInfoData)
        
        //MARK: parsing articles data using ArticleParser
        do {
            
            try await withThrowingTaskGroup(of: Article.self) { group in
                
                for articleData in articleDatas {
                    group.addTask {
                        return try await Self.articleParser.parse(from: articleData)
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
    
    
    
    public func parse(directoryURL: URL) async throws -> Story {
        let storyInfoFileURL = directoryURL
            .appendingPathComponent("Story")
            .appendingPathExtension("txt")
        
        guard let storyInfoData = FileManager.default.contents(atPath: storyInfoFileURL.path) else {
            throw StoryParsingError("Story.txtファイル読むの失敗したね。")
        }
        
        var (result, articleCount) = try parseStoryInfo(from: storyInfoData)
        
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
                    return try await Self.articleParser.parse(from: articleData)
                }
            }
            
            for try await article in group {
                result.articles.append(article)
            }
        }
        
        return result
    }
    
    
    
    private func parseStoryInfo(from data: Data) throws -> (Story, articleCount: Int) {
        guard let text = String(data: data, encoding: .utf8) else {
            throw StoryParsingError.invalidTextCoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw StoryParsingError.dataCorrupted
        }
        
        guard let createdDate = Self.dateFormatter.date(from: match.group(named: "createdAt")!),
              let exportedDate = Self.dateFormatter.date(from: match.group(named: "exportedAt")!)
        else {
            throw StoryParsingError.invalidDateFormat
        }
        
        guard let articleCount = Int(match.group(named: "articleCount")!) else {
            throw StoryParsingError.invalidNumberFormat
        }
        
        return (
            Story(
                title: match.group(named: "title")!,
                subtitle: match.group(named: "subtitle")!,
                createdDate: createdDate,
                exportedDate: exportedDate,
                articles: []
            ),
            articleCount: articleCount
        )
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
        
        static let invalidTextCoding = Self.init("テキストコーディングがだめね。")
        
        static let dataCorrupted = Self.init("中身が腐ってるね。")
        
        static let invalidDateFormat = Self.init("日時のフォーマットがなってないね。")
        
        static let invalidNumberFormat = Self.init("数字のフォーマットがなってないね")
    }
}
