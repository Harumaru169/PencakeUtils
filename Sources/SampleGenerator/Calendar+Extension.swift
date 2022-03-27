//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

extension Calendar {
    func truncatingSeconds(of date: Date) -> Date {
        let dateComponents = self.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return self.date(from: dateComponents)!
    }
}
