//
//  File.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation
import Regex

public final class StoryInfoParser: StoryInfoParserProtocol {
    public init() {}
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return df
    }()
    
    private static let regex = try! Regex(
        pattern: "# Title(\n|\r\n)(.*)\\1{2}# Subtitle\\1(.*)\\1{2}# Created at\\1(.*)\\1{2}# Exported at\\1(.*)\\1{2}# Article count\\1([0-9]*)\\1{2}# Articles\\1([\\s\\S]*)\\1",
        groupNames: "lineBreak", "title", "subtitle", "createdAt", "exportedAt", "articleCount", "articles"
    )
    
    public func parse(from data: Data) async throws -> StoryInformation {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.dataCorrupted
        }
        
        let createdDateString = match.group(named: "createdAt")!
        guard let createdDate = Self.dateFormatter.date(from: createdDateString) else {
            throw ParseError.invalidDateFormat(dateString: createdDateString)
        }
        
        let exportedDateString = match.group(named: "exportedAt")!
        guard let exportedDate = Self.dateFormatter.date(from: exportedDateString) else {
            throw ParseError.invalidDateFormat(dateString: exportedDateString)
        }
        
        
        let articleCountString = match.group(named: "articleCount")!
        guard let articleCount = Int(articleCountString) else {
            throw ParseError.invalidNumberFormat(numberString: articleCountString)
        }
        
        return StoryInformation(
            title: match.group(named: "title")!,
            subtitle: match.group(named: "subtitle")!,
            createdDate: createdDate,
            exportedDate: exportedDate,
            articleCount: articleCount
        )
    }
    
    public func parse(fileURL: URL) async throws -> StoryInformation {
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile(fileName: fileURL.lastPathComponent)
        }
        
        return try await parse(from: data)
    }
}

//TODO: CustomStringConvertible
extension StoryInfoParser {
    public enum ParseError: Error, CustomStringConvertible {
        case invalidTextEncoding
        
        case dataCorrupted
        
        case invalidDateFormat(dateString: String)
        
        case invalidNumberFormat(numberString: String)
        
        case failedToReadFile(fileName: String)
        
        public var description: String {
            switch self {
                case .invalidTextEncoding:
                    return "Invalid text encoding."
                case .dataCorrupted:
                    return "The content does not follow the format."
                case .invalidDateFormat(let dateString):
                    return "Invalid date format: \(dateString)"
                case .invalidNumberFormat(let numberString):
                    return "Invalid number format: \(numberString)"
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName) file."
            }
        }
    }
}
