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
            NavigationView {
                KodoListView(isText: $isText, isMove: $isMove)
                    .toolbar
                {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button(action: {
                            isMove.toggle()
                        }) {
                            Image(systemName: isMove ? "figure.stand" : "figure.walk")
                                .font(Font.system(size: 25, weight: .regular))
                        }
                    }
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
