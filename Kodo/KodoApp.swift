//
//  KodoApp.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI

@main
struct KodoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                KodoListView()
            }
            .toolbar {
                Button(action: {
                    // TODO Action
                }) {
                    Image(systemName: "textformat.abc.dottedunderline")
                }
            }
        }
    }
}
