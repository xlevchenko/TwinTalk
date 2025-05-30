//
//  DateFormatter + Ext.swift
//  TwinTalk
//
//  Created by Olexsii Levchenko on 30.05.2025.
//

import Foundation

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
