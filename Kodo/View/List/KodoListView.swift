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
    @Binding var isMove: Bool

    @State private var isShowDetail: Bool = false
    @State private var selectedIndex: Int = 0

    let creatures: [Creature] = [
        .init(name: "人間",
              images: [
                UIImage(named: "human_1")!,
                UIImage(named: "human_2")!,
                UIImage(named: "human_3")!,
                UIImage(named: "human_4")!,
                UIImage(named: "human_3")!,
                UIImage(named: "human_2")!
              ],
              heartbeat: 0.85),
        .init(name: "すずめ",
              images: [
                UIImage(named: "suzume_1")!,
                UIImage(named: "suzume_2")!,
                UIImage(named: "suzume_3")!,
                UIImage(named: "suzume_4")!,
                UIImage(named: "suzume_5")!,
                UIImage(named: "suzume_6")!,
                UIImage(named: "suzume_7")!,
                UIImage(named: "suzume_8")!,
                UIImage(named: "suzume_9")!,
                UIImage(named: "suzume_10")!
              ],
              heartbeat: 0.075),
        .init(name: "ぞう",
              images: [
                UIImage(named: "elephant_1")!,
                UIImage(named: "elephant_2")!,
                UIImage(named: "elephant_3")!,
                UIImage(named: "elephant_4")!,
                UIImage(named: "elephant_5")!,
                UIImage(named: "elephant_6")!,
                UIImage(named: "elephant_7")!,
                UIImage(named: "elephant_8")!,
                UIImage(named: "elephant_9")!,
                UIImage(named: "elephant_10")!,
                UIImage(named: "elephant_11")!,
                UIImage(named: "elephant_12")!,
                UIImage(named: "elephant_13")!
              ],
              heartbeat: 3),
        .init(name: "たこ",
              images: [
                UIImage(named: "octopus_1")!,
                UIImage(named: "octopus_2")!,
                UIImage(named: "octopus_3")!,
                UIImage(named: "octopus_4")!,
                UIImage(named: "octopus_3")!,
                UIImage(named: "octopus_2")!
              ],
              heartbeat: 1.7),
        .init(name: "にわとり",
              images: [
                UIImage(named: "chicken_1")!,
                UIImage(named: "chicken_2")!,
                UIImage(named: "chicken_3")!,
                UIImage(named: "chicken_4")!,
                UIImage(named: "chicken_3")!,
                UIImage(named: "chicken_2")!
              ],
              heartbeat: 0.3),
        .init(name: "ねこ",
              images: [
                UIImage(named: "cat_1")!,
                UIImage(named: "cat_2")!,
                UIImage(named: "cat_3")!,
                UIImage(named: "cat_4")!,
                UIImage(named: "cat_3")!,
                UIImage(named: "cat_2")!
              ],
              heartbeat: 0.5),
        .init(name: "犬",
              images: [
                UIImage(named: "dog_1")!,
                UIImage(named: "dog_2")!,
                UIImage(named: "dog_3")!,
                UIImage(named: "dog_4")!,
                UIImage(named: "dog_3")!,
                UIImage(named: "dog_2")!
              ],
              heartbeat: 1.2),
        .init(name: "馬",
              images: [
                UIImage(named: "pony_1")!,
                UIImage(named: "pony_2")!,
                UIImage(named: "pony_3")!,
                UIImage(named: "pony_4")!,
                UIImage(named: "pony_3")!,
                UIImage(named: "pony_2")!
              ],
              heartbeat: 1.5),
        .init(name: "ネズミ",
              images: [
                UIImage(named: "mouth_1")!,
                UIImage(named: "mouth_2")!,
                UIImage(named: "mouth_3")!,
                UIImage(named: "mouth_4")!,
                UIImage(named: "mouth_3")!,
                UIImage(named: "mouth_2")!
              ],
              heartbeat: 0.2),
    ]

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 10
            let length = min(geometry.size.width, geometry.size.height) / 2 - spacing
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: spacing) {
                            ForEach(Array(creatures.enumerated()), id: \.element) { index, creature in
                                Group {
                                    if isText {
                                        CreatureTextView(isMove: $isMove,
                                                         creature: creature,
                                                         length: length)
                                    } else {
                                        CreatureImageView(creature: creature,
                                                          length: length,
                                                          isMove: $isMove)
                                    }
                                }
                                .onTapGesture{
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        self.selectedIndex = index
                                        isShowDetail.toggle()
                                    }
                                }
                            }
                            .fullScreenCover(isPresented: $isShowDetail) {
                                CreatureDetailView(creatures: creatures,
                                                   isShowDetail: $isShowDetail,
                                                   index: $selectedIndex)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct KodoListView_Previews: PreviewProvider {
    static var previews: some View {
        KodoListView(isText: .constant(true), isMove: .constant(true))
    }
}
