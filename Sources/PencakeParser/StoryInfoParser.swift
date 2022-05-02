//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import Regex

public final class StoryInfoParser: StoryInfoParserProtocol {
    public init() {}
    
    private static let dateFormatter = DateFormatConstants.formatterForStoryInfo()
    
    private static let regex = try! Regex(
        pattern: "# Title(\(Newline.regexMatchingAnyNewline))(.*)\\1{2}# Subtitle\\1(.*)\\1{2}# Created at\\1(.*)\\1{2}# Exported at\\1(.*)\\1{2}# Article count\\1([0-9]*)\\1{2}# Articles\\1([\\s\\S]*)\\1",
        groupNames: "newline", "title", "subtitle", "createdAt", "exportedAt", "articleCount", "articles"
    )
    
    public func parse(from data: Data) throws -> StoryInfo {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.invalidFormat
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
        let articleCount = Int(articleCountString)!
        
        return StoryInfo(
            title: match.group(named: "title")!,
            subtitle: match.group(named: "subtitle")!,
            createdDate: createdDate,
            exportedDate: exportedDate,
            articleCount: articleCount
        )
    }
    
    public func parse(fileURL: URL) throws -> StoryInfo {
        let fileManager = FileManager.default
        
        let fileType = try fileManager.type(at: fileURL)
        guard fileType == .typeRegular else {
            throw ParseError.unexpectedFileType(path: fileURL.path, expected: .typeRegular, actual: fileType)
        }
        
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile(path: fileURL.path)
        }
        
        return try parse(from: data)
    }
}
