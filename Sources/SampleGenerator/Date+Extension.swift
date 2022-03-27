//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation

extension Date {
    static func random(in range: Range<Date>) -> Date {
        let timeIntervalRange = range.lowerBound.timeIntervalSinceNow...range.upperBound.timeIntervalSinceNow
        return Date(timeIntervalSinceNow: .random(in: timeIntervalRange))
    }
}
