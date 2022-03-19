// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

struct PreparationError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
