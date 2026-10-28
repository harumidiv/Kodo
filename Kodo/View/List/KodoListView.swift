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

    @State private var isShowDetail: Bool = ProcessInfo.processInfo.environment["SS_DETAIL"] != nil
    @State private var selectedIndex: Int = Int(ProcessInfo.processInfo.environment["SS_DETAIL"] ?? "") ?? 0

    let creatures: [Creature] = [
        .init(name: "人間",
              scientificName: "Homo sapiens",
              images: [
                UIImage(named: "human_1")!,
                UIImage(named: "human_2")!,
                UIImage(named: "human_3")!,
                UIImage(named: "human_4")!,
                UIImage(named: "human_3")!,
                UIImage(named: "human_2")!
              ],
              states: [
                .init(name: "安静", heartbeat: 0.85),
                .init(name: "運動", heartbeat: 0.4),
                .init(name: "睡眠", heartbeat: 1.1)
              ]),
        .init(name: "すずめ",
              scientificName: "Passer montanus",
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
              states: [
                .init(name: "安静", heartbeat: 0.075),
                .init(name: "飛行中", heartbeat: 0.06)
              ]),
        .init(name: "ぞう",
              scientificName: "Elephas maximus",
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
              scientificName: "Octopus vulgaris",
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
              scientificName: "Gallus gallus domesticus",
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
              scientificName: "Felis catus",
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
              scientificName: "Canis familiaris",
              images: [
                UIImage(named: "dog_1")!,
                UIImage(named: "dog_2")!,
                UIImage(named: "dog_3")!,
                UIImage(named: "dog_4")!,
                UIImage(named: "dog_3")!,
                UIImage(named: "dog_2")!
              ],
              states: [
                .init(name: "安静", heartbeat: 0.7),
                .init(name: "運動", heartbeat: 0.33)
              ]),
        .init(name: "馬",
              scientificName: "Equus caballus",
              images: [
                UIImage(named: "pony_1")!,
                UIImage(named: "pony_2")!,
                UIImage(named: "pony_3")!,
                UIImage(named: "pony_4")!,
                UIImage(named: "pony_3")!,
                UIImage(named: "pony_2")!
              ],
              states: [
                .init(name: "安静", heartbeat: 1.5),
                .init(name: "全力疾走", heartbeat: 0.27)
              ]),
        .init(name: "ネズミ",
              scientificName: "Mus musculus",
              images: [
                UIImage(named: "mouth_1")!,
                UIImage(named: "mouth_2")!,
                UIImage(named: "mouth_3")!,
                UIImage(named: "mouth_4")!,
                UIImage(named: "mouth_3")!,
                UIImage(named: "mouth_2")!
              ],
              heartbeat: 0.11),
    ]

    var body: some View {
        GeometryReader { geometry in
            let cellWidth = (geometry.size.width - SpecimenStyle.ruleWidth) / 2
            ZStack {
                SpecimenStyle.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    ScrollView {
                        // 罫線はセルの隙間から見える背景色で描く
                        if isText {
                            LazyVStack(spacing: SpecimenStyle.ruleWidth) {
                                ForEach(Array(creatures.enumerated()), id: \.element) { index, creature in
                                    CreatureTextView(number: index + 1,
                                                     creature: creature)
                                        .onTapGesture { showDetail(index: index) }
                                }
                            }
                            .background(SpecimenStyle.rule)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: SpecimenStyle.ruleWidth),
                                                GridItem(.flexible(), spacing: SpecimenStyle.ruleWidth)],
                                      spacing: SpecimenStyle.ruleWidth) {
                                ForEach(Array(creatures.enumerated()), id: \.element) { index, creature in
                                    specimenCell(index: index, creature: creature, width: cellWidth)
                                        .onTapGesture { showDetail(index: index) }
                                }
                            }
                            .background(SpecimenStyle.rule)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowDetail) {
                CreatureDetailView(creatures: creatures,
                                   isText: isText,
                                   isShowDetail: $isShowDetail,
                                   index: $selectedIndex)
            }
        }
    }

    private func showDetail(index: Int) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            self.selectedIndex = index
            isShowDetail.toggle()
        }
    }

    // MARK: - View Component

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    isMove.toggle()
                }) {
                    Image(systemName: isMove ? "figure.stand" : "figure.walk")
                        .font(.system(size: 18, weight: .regular))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(SpecimenStyle.border, lineWidth: 1))
                }
                .accessibilityLabel(isMove ? "動きを止める" : "動かす")
                // 文字表示では心電図が常に動くので、動きの切り替えは隠す
                .opacity(isText ? 0 : 1)
                .disabled(isText)
                Spacer()
                Button(action: {
                    isText.toggle()
                }) {
                    Text(isText ? "画像" : "文字")
                        .font(SpecimenStyle.mono(13))
                        .tracking(1)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .overlay(Capsule().stroke(SpecimenStyle.border, lineWidth: 1))
                }
                .accessibilityLabel(isText ? "画像表示に切り替える" : "文字表示に切り替える")
            }
            .foregroundColor(SpecimenStyle.ink)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("鼓動標本")
                    .font(SpecimenStyle.mincho(36, bold: true))
                    .tracking(1.5)
                    .foregroundColor(SpecimenStyle.ink)
                Text("KODO SPECIMENS · \(creatures.count) SPECIES · BPM")
                    .font(SpecimenStyle.mono(11))
                    .tracking(1.8)
                    .foregroundColor(SpecimenStyle.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 16)

            SpecimenStyle.rule.frame(height: SpecimenStyle.ruleWidth)
        }
    }

    private func specimenCell(index: Int, creature: Creature, width: CGFloat) -> some View {
        let imageLength = width * 0.62
        return VStack(spacing: 0) {
            HStack {
                Text("No.\(SpecimenStyle.number(index + 1))")
                    .foregroundColor(SpecimenStyle.muted)
                Spacer()
                Text("\(SpecimenStyle.bpm(creature.heartbeat)) bpm")
                    .foregroundColor(SpecimenStyle.heart)
            }
            .font(SpecimenStyle.mono(11))
            .tracking(0.8)
            Spacer(minLength: 0)
            CreatureImageView(creature: creature,
                              length: imageLength,
                              isMove: $isMove)
            Spacer(minLength: 0)
            Text(creature.name)
                .font(SpecimenStyle.mincho(16))
                .tracking(1.2)
                .foregroundColor(SpecimenStyle.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: width, height: width * 1.12)
        .background(SpecimenStyle.background)
        .contentShape(Rectangle())
    }
}

/// 標本箱デザインの色と文字
enum SpecimenStyle {
    static let background = Color(red: 5 / 255, green: 5 / 255, blue: 5 / 255)
    static let ink = Color(red: 236 / 255, green: 232 / 255, blue: 227 / 255)
    static let muted = Color(red: 143 / 255, green: 138 / 255, blue: 132 / 255)
    static let rule = Color(red: 42 / 255, green: 40 / 255, blue: 38 / 255)
    static let border = Color(red: 58 / 255, green: 55 / 255, blue: 52 / 255)
    static let heart = Color(red: 1, green: 90 / 255, blue: 82 / 255)
    static let ruleWidth: CGFloat = 1

    static func mincho(_ size: CGFloat, bold: Bool = false) -> Font {
        .custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size)
    }

    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    static func bpm(_ heartbeat: Double) -> Int {
        Int((60 / heartbeat).rounded())
    }

    static func number(_ value: Int) -> String {
        String(format: "%02d", value)
    }
}

struct KodoListView_Previews: PreviewProvider {
    static var previews: some View {
        KodoListView(isText: .constant(true), isMove: .constant(true))
    }
}
