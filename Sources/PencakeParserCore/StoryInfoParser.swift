//
//  File.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation
import Regex

public class StoryInfoParser {
    private init() {}
    
    public static let shared: StoryInfoParser = .init()
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return df
    }()
    
    private static let regex = try! Regex(
        pattern: "# Title(\n|\r\n)(.*)\\1{2}# Subtitle\\1(.*)\\1{2}# Created at\\1(.*)\\1{2}# Exported at\\1(.*)\\1{2}# Article count\\1([0-9]*)\\1{2}# Articles\\1([\\s\\S]*)\\1",
        groupNames: "lineBreak", "title", "subtitle", "createdAt", "exportedAt", "articleCount", "articles"
    )
    
    public func parse(from data: Data) async throws -> (Story, articleCount: Int) {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.dataCorrupted
        }
        
        guard let createdDate = Self.dateFormatter.date(from: match.group(named: "createdAt")!),
              let exportedDate = Self.dateFormatter.date(from: match.group(named: "exportedAt")!)
        else {
            throw ParseError.invalidDateFormat
        }
        
        guard let articleCount = Int(match.group(named: "articleCount")!) else {
            throw ParseError.invalidNumberFormat
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
    
    public func parse(fileURL: URL) async throws -> (Story, articleCount: Int) {
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile
        }
        
        return try await parse(from: data)
    }
}

extension StoryInfoParser {
    public enum ParseError: Error {
        case invalidTextEncoding
        
        case dataCorrupted
        
        case invalidDateFormat
        
        case invalidNumberFormat
        
        case failedToReadFile
    }
}
