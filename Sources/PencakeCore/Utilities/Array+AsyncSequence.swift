//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

extension Array {
    public init<S>(_ asyncSequence: S) async rethrows where Element == S.Element, S : AsyncSequence {
        self = try await asyncSequence.reduce(into: [Element](), { partialResult, element in
            partialResult.append(element)
        })
    }
}
