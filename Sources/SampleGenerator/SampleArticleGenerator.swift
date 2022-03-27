//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import XCTest

public final class SampleArticleGenerator {
    public static let `default` = SampleArticleGenerator()
    
    public init() {}
    
    public func generateArticleAndFileWrapper(number: Int, options: GenerateOptions) -> (Article, FileWrapper) {
        let (article, data) = generateArticleAndData(number: number, options: options)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        
        return (article, fileWrapper)
    }
    
    public func generateArticleAndData(number: Int, options: GenerateOptions) -> (Article, Data) {
        let titleText = generateTitleText(number: number, options: options)
        var editDate = Date.random(in: Date(timeIntervalSince1970: 0)..<Date.now)
        editDate = Calendar(identifier: .gregorian).truncatingSeconds(of: editDate)
        let editDateString = generateDateString(date: editDate, options: options)
        let bodyText = generateBodyText(options: options)
        
        let doubleNewline = String(repeating: options.newline.rawString, count: 2)
        let data = "\(titleText)\(doubleNewline)\(editDateString)\(doubleNewline)\(bodyText)".data(using: .utf8)!
        
        let article = Article(title: titleText, editDate: editDate, body: bodyText)
        
        return (article, data)
    }
    
    private func generateBodyText(options: GenerateOptions) -> String {
        return { () -> String in
            switch options.language {
                case .english: return Self.englishBodyText
                case .japanese: return Self.japaneseBodyText
            }
        }().replacingOccurrences(of: "*NEWLINE*", with: options.newline.rawString)
    }
    
    private func generateTitleText(number: Int, options: GenerateOptions) -> String {
        return { () -> String in
            switch options.language {
                case .english: return Self.englishTitleText
                case .japanese: return Self.japaneseTitleText
            }
        }().replacingOccurrences(of: "*NUMBER*", with: String(number))
    }
    
    private func generateDateString(date: Date, options: GenerateOptions) -> String {
        switch options.language {
            case .english: return Self.englishDateFormatter.string(from: date)
            case .japanese: return Self.japaneseDateFormatter.string(from: date)
        }
    }
}

extension SampleArticleGenerator {
    //Use *NEWLINE* as a placeholder for the newline character, as it varies depending on the situation.
    private static let englishBodyText = "Live as if you were to die tomorrow. Learn as if you were to live forever.*NEWLINE*- Mahatma Gandhi"
    private static let japaneseBodyText = "明日死ぬつもりで生きろ。永遠に生き続けるかのように学びなさい。*NEWLINE*- マハトマ・ガンジー"
    
    //Similarly, use *NUMBER* as a placeholder for the article number.
    private static let englishTitleText = "Sample Article No.*NUMBER*"
    
    private static let japaneseTitleText = "サンプル記事 No.*NUMBER*"
    
    private static let englishDateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        return dateFormatter
    }()
    
    private static let japaneseDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年M月d日(E) HH:mm"
        return dateFormatter
    }()
}
