//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import RegexBuilder

public final class ArticleParser<NewlineReplacerType: NewlineReplacerProtocol>: ArticleParserProtocol {
    
    private let newlineReplacer: NewlineReplacerType
    
    init(newlineReplacer: NewlineReplacerType) {
        self.newlineReplacer = newlineReplacer
    }
    
    private let regex = Regex {
        let newline = #/\r?\n/#
        
        Capture {
            OneOrMore(.any)
        }
        
        Repeat(newline, count: 2)
        
        Capture {
            OneOrMore(.any)
        }
        
        Repeat(newline, count: 2)
        
        Capture {
            OneOrMore {
                ChoiceOf {
                    CharacterClass.any
                    newline
                }
            }
        }
    }
    
    public func parse(from data: Data, options: ParseOptions) throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = text.firstMatch(of: regex) else {
            throw ParseError.invalidFormat
        }
        
        let (_, title, editDateString, rawBody) = match.output
        
        let body: String
        if let newline = options.newline {
            body = newlineReplacer.replacingAll(in: String(rawBody), with: newline)
        } else {
            body = String(rawBody)
        }
        
        let dateFormatter = DateFormatConstants.formatterForArticle(in: options.language)
        guard let editDate = dateFormatter.date(from: String(editDateString))
        else {
            throw ParseError.invalidDateFormat(dateString: String(editDateString))
        }
        
        return Article(title: String(title), editDate: editDate, body: body)
    }
    
    public func parse(fileURL: URL, options: ParseOptions) throws -> Article {
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile(path: fileURL.path)
        }
        
        return try parse(from: data, options: options)
    }
}

extension ArticleParser where NewlineReplacerType == NewlineReplacer {
    public convenience init() {
        self.init(newlineReplacer: .init())
    }
}
