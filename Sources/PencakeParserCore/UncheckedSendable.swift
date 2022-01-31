//
//  UncheckedSendable.swift
//  
//
//  Created by k.haruyama on 2022/01/31.
//  
//

import Foundation

extension Date: @unchecked Sendable {}

extension Data: @unchecked Sendable {}

extension URL: @unchecked Sendable {}
