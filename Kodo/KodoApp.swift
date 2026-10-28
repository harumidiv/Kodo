//
//  KodoApp.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI

@main
struct KodoApp: App {
    @State private var isText: Bool = ProcessInfo.processInfo.environment["SS_TEXT"] == "1"
    @State private var isMove: Bool = ProcessInfo.processInfo.environment["SS_MOVE"] == "1"

    var body: some Scene {
        WindowGroup {
            KodoListView(isText: $isText, isMove: $isMove)
                .preferredColorScheme(.dark)
        }
    }
}
