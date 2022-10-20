//
//  Task+Addition.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1000 * 1000 * 1000)
        try await Task.sleep(nanoseconds: delay)
    }

    static func sleep(millisecond duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1000 * 1000)
        try await Task.sleep(nanoseconds: delay)
    }

    static func sleep(microseconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1000)
        try await Task.sleep(nanoseconds: delay)
    }
}
