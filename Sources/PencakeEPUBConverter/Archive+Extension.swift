//
// The MIT License (MIT)
//
// Copyright (c) 2024 Kosei Haruyama.
//

import Foundation
import ZIPFoundation

extension Archive {
    func addData(_ data: Data, with path: String) throws {
        let dataSize = data.count
        //It is essential to specify the buffer size of entries.
        try self.addEntry(with: path, type: .file, uncompressedSize: Int64(dataSize), bufferSize: dataSize) { position, size in
            data
        }
    }
}
