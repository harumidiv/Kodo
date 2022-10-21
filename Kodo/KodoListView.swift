//
//  KodoListView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI
import UIKit

struct KodoListView: View {
    @Binding var isText: Bool

    @State var timer :Timer?
    @State var isTapped: Bool = false

    let creatures: [Creature] = [
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85),
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85)
    ]

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 10
            let length = min(geometry.size.width, geometry.size.height) / 3 - spacing
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: spacing) {
                        ForEach(creatures) { creature in
                            if isText {
                                CreatureTextView(creature: creature, length: length)
                            } else {
                                CreatureImageView(creature: creature,
                                                  length: length,
                                                  timer: $timer,
                                                  isTapped: $isTapped)

                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 4)
                        )


                    }
                    Spacer()
                }
            }
        }
    }
}

struct KodoListView_Previews: PreviewProvider {
    static var previews: some View {
        KodoListView(isText: .constant(true))
    }
}
