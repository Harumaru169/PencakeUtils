//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import RegexBuilder

public final class StoryInfoParser: StoryInfoParserProtocol {
    public init() {}
    
    private let regex: Regex = {
        let newline = #/\r|\n|\r\n/#
        let doubleNewline = Repeat(newline, count: 2)
        let dateFormatter = DateFormatConstants.formatterForStoryInfo()
        
        return Regex {
            "# Title"
            newline
            Capture { ZeroOrMore(.any) }
            
            doubleNewline
            
            "# Subtitle"
            newline
            Capture { ZeroOrMore(.any) }
            
            doubleNewline
            
            "# Created at"
            newline
            TryCapture { OneOrMore(.any) } transform: { (createdDateString: Substring) -> Date? in
                dateFormatter.date(from: String(createdDateString))
            }
            
            doubleNewline
            
            "# Exported at"
            newline
            TryCapture { OneOrMore(.any) } transform: { (exportedDateString: Substring) -> Date? in
                dateFormatter.date(from: String(exportedDateString))
            }
            
            doubleNewline
            
            "# Article count"
            newline
            Capture {
                .localizedInteger
            }
            
            doubleNewline
            
            "# Articles"
            newline
            ZeroOrMore {
                #/[\s\S]/#
            }
            newline
        }
    }()
    
    public func parse(from data: Data) throws -> StoryInfo {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = text.wholeMatch(of: regex) else {
            throw ParseError.invalidFormat
        }
        
        let (_, title, subtitle, createdDate, exportedDate, articleCount): (Substring, Substring, Substring, Date, Date, Int) = match.output
        
        return StoryInfo(
            title: String(title),
            subtitle: String(subtitle),
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
