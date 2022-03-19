//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

public enum DateFormatConstants {
    
    public static func formatterForArticle(in language: Language) -> DateFormatter {
        let formatter = DateFormatter()
        
        switch language {
            case .english:
                formatter.locale = .init(identifier: "en_US")
                formatter.dateFormat = "EEE, MMM dd, yyyy hh:mm a"
            case .japanese:
                formatter.locale = Locale(identifier: "ja_JP")
                formatter.dateFormat = "yyyy年MM月dd日(E) HH:mm"
        }
        
        return formatter
    }
    
    public static func formatterForStoryInfo() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }
}
