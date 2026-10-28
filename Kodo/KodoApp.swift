//
//  KodoApp.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI

@main
struct KodoApp: App {
    @State private var isText: Bool = false
    @State private var isMove: Bool = false

    var body: some Scene {
        WindowGroup {
            KodoListView(isText: $isText, isMove: $isMove)
                .preferredColorScheme(.dark)
        }
    }
}
