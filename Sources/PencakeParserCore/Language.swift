//
//  Language.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation

public enum Language: String, RawRepresentable, CaseIterable, Codable {
    case english
    case japanese
}

extension Language {
    internal var dateFormatterForArticle: DateFormatter {
        let df = DateFormatter()
        
        switch self {
            case .english:
                df.locale = .init(identifier: "en_US")
                df.dateFormat = "EEE, MMM dd, yyyy hh:mm a"
            case .japanese:
                df.locale = Locale(identifier: "ja_JP")
                df.dateFormat = "yyyy年MM月dd日(E) HH:mm"
        }
        
        return df
    }
}
