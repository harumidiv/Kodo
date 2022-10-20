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

    var body: some Scene {
        WindowGroup {
            NavigationView {
                KodoListView(isText: $isText)
                    .toolbar
                {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isText.toggle()
                        }) {
                            Image(systemName: isText ? "photo" : "textformat.abc.dottedunderline")
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
