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
    @StateObject private var nativeAdLoader: NativeAdLoader

    /// 広告1つあたりの生物の数。この数ごとに区切った範囲に広告を1つずつ入れる
    private static let creaturesPerAd = 11

    /// ネイティブ広告を何番目の生物の前に入れるか（キー）と、何番目の広告枠か（値）。
    /// 起動ごとにランダムに決め、表示中は動かさない
    @State private var nativeAdSlots: [Int: Int]

    init(isText: Binding<Bool>, isMove: Binding<Bool>) {
        _isText = isText
        _isMove = isMove
        let positions = Self.makeNativeAdPositions(creatureCount: creatures.count)
        _nativeAdSlots = State(initialValue: Dictionary(uniqueKeysWithValues: positions.enumerated().map { ($1, $0) }))
        _nativeAdLoader = StateObject(wrappedValue: NativeAdLoader(numberOfAds: positions.count))
    }

    /// 区切った範囲ごとにランダムな位置を1つ選ぶ。
    /// 一覧の先頭は生物から始めたいので1番目の前には入れず、範囲の両端も避けて広告どうしが隣り合わないようにする
    private static func makeNativeAdPositions(creatureCount: Int) -> [Int] {
        let adCount = max(1, creatureCount / creaturesPerAd)
        return (0..<adCount).compactMap { block in
            let lower = max(1, block * creaturesPerAd + 1)
            let upper = min(creatureCount, (block + 1) * creaturesPerAd - 1)
            return lower < upper ? Int.random(in: lower..<upper) : nil
        }
    }

    let creatures: [Creature] = [
        .init(name: String(localized: "人間"),
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
                .init(name: String(localized: "安静"), heartbeat: 0.85),
                .init(name: String(localized: "運動"), heartbeat: 0.4),
                .init(name: String(localized: "睡眠"), heartbeat: 1.1)
              ]),
        .init(name: String(localized: "すずめ"),
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
                .init(name: String(localized: "安静"), heartbeat: 0.075),
                .init(name: String(localized: "飛行中"), heartbeat: 0.06)
              ]),
        .init(name: String(localized: "ぞう"),
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
        .init(name: String(localized: "たこ"),
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
        .init(name: String(localized: "にわとり"),
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
        .init(name: String(localized: "ねこ"),
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
        .init(name: String(localized: "犬"),
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
                .init(name: String(localized: "安静"), heartbeat: 0.7),
                .init(name: String(localized: "運動"), heartbeat: 0.33)
              ]),
        .init(name: String(localized: "馬"),
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
                .init(name: String(localized: "安静"), heartbeat: 1.5),
                .init(name: String(localized: "全力疾走"), heartbeat: 0.27)
              ]),
        .init(name: String(localized: "ネズミ"),
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
        .init(name: String(localized: "コウモリ"),
              scientificName: "Pipistrellus abramus",
              images: [
                UIImage(named: "bat_1")!,
                UIImage(named: "bat_2")!,
                UIImage(named: "bat_3")!,
                UIImage(named: "bat_4")!,
                UIImage(named: "bat_3")!,
                UIImage(named: "bat_2")!
              ],
              states: [
                .init(name: String(localized: "安静"), heartbeat: 0.15),
                .init(name: String(localized: "飛行中"), heartbeat: 0.07)
              ]),
        .init(name: String(localized: "カブトムシ"),
              scientificName: "Trypoxylus dichotomus",
              images: [
                UIImage(named: "beetle_1")!,
                UIImage(named: "beetle_2")!,
                UIImage(named: "beetle_3")!,
                UIImage(named: "beetle_4")!,
                UIImage(named: "beetle_5")!,
                UIImage(named: "beetle_6")!,
                UIImage(named: "beetle_7")!,
                UIImage(named: "beetle_6")!,
                UIImage(named: "beetle_5")!,
                UIImage(named: "beetle_4")!,
                UIImage(named: "beetle_3")!,
                UIImage(named: "beetle_2")!
              ],
              heartbeat: 0.8),
        .init(name: String(localized: "アゲハ蝶"),
              scientificName: "Papilio xuthus",
              images: [
                UIImage(named: "butterfly_1")!,
                UIImage(named: "butterfly_2")!,
                UIImage(named: "butterfly_3")!,
                UIImage(named: "butterfly_4")!,
                UIImage(named: "butterfly_5")!,
                UIImage(named: "butterfly_6")!,
                UIImage(named: "butterfly_7")!,
                UIImage(named: "butterfly_6")!,
                UIImage(named: "butterfly_5")!,
                UIImage(named: "butterfly_4")!,
                UIImage(named: "butterfly_3")!,
                UIImage(named: "butterfly_2")!
              ],
              heartbeat: 1.2),
        .init(name: String(localized: "ムカデ"),
              scientificName: "Scolopendra subspinipes",
              images: [
                UIImage(named: "centipede_1")!,
                UIImage(named: "centipede_2")!,
                UIImage(named: "centipede_3")!,
                UIImage(named: "centipede_4")!,
                UIImage(named: "centipede_5")!,
                UIImage(named: "centipede_6")!,
                UIImage(named: "centipede_5")!,
                UIImage(named: "centipede_4")!,
                UIImage(named: "centipede_3")!,
                UIImage(named: "centipede_2")!
              ],
              heartbeat: 0.75),
        .init(name: String(localized: "カメレオン"),
              scientificName: "Chamaeleo calyptratus",
              images: [
                UIImage(named: "chameleon_1")!,
                UIImage(named: "chameleon_2")!,
                UIImage(named: "chameleon_3")!,
                UIImage(named: "chameleon_4")!,
                UIImage(named: "chameleon_5")!,
                UIImage(named: "chameleon_6")!,
                UIImage(named: "chameleon_7")!,
                UIImage(named: "chameleon_6")!,
                UIImage(named: "chameleon_5")!,
                UIImage(named: "chameleon_4")!,
                UIImage(named: "chameleon_3")!,
                UIImage(named: "chameleon_2")!
              ],
              heartbeat: 1.0),
        .init(name: String(localized: "トンボ"),
              scientificName: "Anax parthenope",
              images: [
                UIImage(named: "dragonfly_1")!,
                UIImage(named: "dragonfly_2")!,
                UIImage(named: "dragonfly_3")!,
                UIImage(named: "dragonfly_4")!,
                UIImage(named: "dragonfly_5")!,
                UIImage(named: "dragonfly_6")!,
                UIImage(named: "dragonfly_5")!,
                UIImage(named: "dragonfly_4")!,
                UIImage(named: "dragonfly_3")!,
                UIImage(named: "dragonfly_2")!
              ],
              heartbeat: 0.6),
        .init(name: String(localized: "カエル"),
              scientificName: "Dryophytes japonicus",
              images: [
                UIImage(named: "frog_1")!,
                UIImage(named: "frog_2")!,
                UIImage(named: "frog_3")!,
                UIImage(named: "frog_4")!,
                UIImage(named: "frog_5")!,
                UIImage(named: "frog_6")!,
                UIImage(named: "frog_5")!,
                UIImage(named: "frog_4")!,
                UIImage(named: "frog_3")!,
                UIImage(named: "frog_2")!
              ],
              heartbeat: 1.5),
        .init(name: String(localized: "キリン"),
              scientificName: "Giraffa camelopardalis",
              images: [
                UIImage(named: "giraffe_1")!,
                UIImage(named: "giraffe_2")!,
                UIImage(named: "giraffe_3")!,
                UIImage(named: "giraffe_4")!,
                UIImage(named: "giraffe_5")!,
                UIImage(named: "giraffe_6")!,
                UIImage(named: "giraffe_5")!,
                UIImage(named: "giraffe_4")!,
                UIImage(named: "giraffe_3")!,
                UIImage(named: "giraffe_2")!
              ],
              heartbeat: 0.9),
        .init(name: String(localized: "バッタ"),
              scientificName: "Locusta migratoria",
              images: [
                UIImage(named: "grasshopper_1")!,
                UIImage(named: "grasshopper_2")!,
                UIImage(named: "grasshopper_3")!,
                UIImage(named: "grasshopper_4")!,
                UIImage(named: "grasshopper_5")!,
                UIImage(named: "grasshopper_6")!,
                UIImage(named: "grasshopper_7")!,
                UIImage(named: "grasshopper_6")!,
                UIImage(named: "grasshopper_5")!,
                UIImage(named: "grasshopper_4")!,
                UIImage(named: "grasshopper_3")!,
                UIImage(named: "grasshopper_2")!
              ],
              heartbeat: 0.7),
        .init(name: String(localized: "ハチドリ"),
              scientificName: "Archilochus colubris",
              images: [
                UIImage(named: "hummingbird_1")!,
                UIImage(named: "hummingbird_2")!,
                UIImage(named: "hummingbird_3")!,
                UIImage(named: "hummingbird_4")!,
                UIImage(named: "hummingbird_3")!,
                UIImage(named: "hummingbird_2")!
              ],
              states: [
                .init(name: String(localized: "安静"), heartbeat: 0.24),
                .init(name: String(localized: "飛行中"), heartbeat: 0.05)
              ]),
        // クラゲには心臓がないので心拍は0
        .init(name: String(localized: "クラゲ"),
              scientificName: "Aurelia aurita",
              images: [
                UIImage(named: "jellyfish_1")!,
                UIImage(named: "jellyfish_2")!,
                UIImage(named: "jellyfish_3")!,
                UIImage(named: "jellyfish_4")!,
                UIImage(named: "jellyfish_5")!,
                UIImage(named: "jellyfish_6")!,
                UIImage(named: "jellyfish_7")!,
                UIImage(named: "jellyfish_8")!,
                UIImage(named: "jellyfish_7")!,
                UIImage(named: "jellyfish_6")!,
                UIImage(named: "jellyfish_5")!,
                UIImage(named: "jellyfish_4")!,
                UIImage(named: "jellyfish_3")!,
                UIImage(named: "jellyfish_2")!
              ],
              heartbeat: 0),
        .init(name: String(localized: "ライオン"),
              scientificName: "Panthera leo",
              images: [
                UIImage(named: "lion_1")!,
                UIImage(named: "lion_2")!,
                UIImage(named: "lion_3")!,
                UIImage(named: "lion_4")!,
                UIImage(named: "lion_5")!,
                UIImage(named: "lion_6")!,
                UIImage(named: "lion_7")!,
                UIImage(named: "lion_6")!,
                UIImage(named: "lion_5")!,
                UIImage(named: "lion_4")!,
                UIImage(named: "lion_3")!,
                UIImage(named: "lion_2")!
              ],
              heartbeat: 1.4),
        .init(name: String(localized: "マンモス"),
              scientificName: "Mammuthus primigenius",
              images: [
                UIImage(named: "mammoth_1")!,
                UIImage(named: "mammoth_2")!,
                UIImage(named: "mammoth_3")!,
                UIImage(named: "mammoth_4")!,
                UIImage(named: "mammoth_5")!,
                UIImage(named: "mammoth_6")!,
                UIImage(named: "mammoth_7")!,
                UIImage(named: "mammoth_8")!,
                UIImage(named: "mammoth_9")!,
                UIImage(named: "mammoth_10")!,
                UIImage(named: "mammoth_11")!,
                UIImage(named: "mammoth_12")!,
                UIImage(named: "mammoth_13")!,
                UIImage(named: "mammoth_12")!,
                UIImage(named: "mammoth_11")!,
                UIImage(named: "mammoth_10")!,
                UIImage(named: "mammoth_9")!,
                UIImage(named: "mammoth_8")!,
                UIImage(named: "mammoth_7")!,
                UIImage(named: "mammoth_6")!,
                UIImage(named: "mammoth_5")!,
                UIImage(named: "mammoth_4")!,
                UIImage(named: "mammoth_3")!,
                UIImage(named: "mammoth_2")!
              ],
              heartbeat: 2.4),
        .init(name: String(localized: "サル"),
              scientificName: "Macaca fuscata",
              images: [
                UIImage(named: "monkey_1")!,
                UIImage(named: "monkey_2")!,
                UIImage(named: "monkey_3")!,
                UIImage(named: "monkey_4")!,
                UIImage(named: "monkey_5")!,
                UIImage(named: "monkey_4")!,
                UIImage(named: "monkey_3")!,
                UIImage(named: "monkey_2")!
              ],
              heartbeat: 0.4),
        .init(name: String(localized: "ペンギン"),
              scientificName: "Aptenodytes forsteri",
              images: [
                UIImage(named: "penguin_1")!,
                UIImage(named: "penguin_2")!,
                UIImage(named: "penguin_3")!,
                UIImage(named: "penguin_4")!,
                UIImage(named: "penguin_5")!,
                UIImage(named: "penguin_6")!,
                UIImage(named: "penguin_5")!,
                UIImage(named: "penguin_4")!,
                UIImage(named: "penguin_3")!,
                UIImage(named: "penguin_2")!
              ],
              states: [
                .init(name: String(localized: "安静"), heartbeat: 0.8),
                .init(name: String(localized: "潜水中"), heartbeat: 3.0)
              ]),
        .init(name: String(localized: "ウサギ"),
              scientificName: "Oryctolagus cuniculus",
              images: [
                UIImage(named: "rabbit_1")!,
                UIImage(named: "rabbit_2")!,
                UIImage(named: "rabbit_3")!,
                UIImage(named: "rabbit_4")!,
                UIImage(named: "rabbit_3")!,
                UIImage(named: "rabbit_2")!
              ],
              heartbeat: 0.28),
        .init(name: String(localized: "タツノオトシゴ"),
              scientificName: "Hippocampus coronatus",
              images: [
                UIImage(named: "seahorse_1")!,
                UIImage(named: "seahorse_2")!,
                UIImage(named: "seahorse_3")!,
                UIImage(named: "seahorse_4")!,
                UIImage(named: "seahorse_3")!,
                UIImage(named: "seahorse_2")!
              ],
              heartbeat: 0.8),
        .init(name: String(localized: "サメ"),
              scientificName: "Carcharodon carcharias",
              images: [
                UIImage(named: "shark_1")!,
                UIImage(named: "shark_2")!,
                UIImage(named: "shark_3")!,
                UIImage(named: "shark_4")!,
                UIImage(named: "shark_5")!,
                UIImage(named: "shark_6")!,
                UIImage(named: "shark_7")!,
                UIImage(named: "shark_8")!,
                UIImage(named: "shark_7")!,
                UIImage(named: "shark_6")!,
                UIImage(named: "shark_5")!,
                UIImage(named: "shark_4")!,
                UIImage(named: "shark_3")!,
                UIImage(named: "shark_2")!
              ],
              heartbeat: 2.0),
        .init(name: String(localized: "ヘビ"),
              scientificName: "Elaphe climacophora",
              images: [
                UIImage(named: "snake_1")!,
                UIImage(named: "snake_2")!,
                UIImage(named: "snake_3")!,
                UIImage(named: "snake_4")!,
                UIImage(named: "snake_5")!,
                UIImage(named: "snake_6")!,
                UIImage(named: "snake_7")!,
                UIImage(named: "snake_8")!,
                UIImage(named: "snake_9")!,
                UIImage(named: "snake_10")!,
                UIImage(named: "snake_9")!,
                UIImage(named: "snake_8")!,
                UIImage(named: "snake_7")!,
                UIImage(named: "snake_6")!,
                UIImage(named: "snake_5")!,
                UIImage(named: "snake_4")!,
                UIImage(named: "snake_3")!,
                UIImage(named: "snake_2")!
              ],
              heartbeat: 1.6),
        .init(name: String(localized: "ティラノサウルス"),
              scientificName: "Tyrannosaurus rex",
              images: [
                UIImage(named: "trex_1")!,
                UIImage(named: "trex_2")!,
                UIImage(named: "trex_3")!,
                UIImage(named: "trex_4")!,
                UIImage(named: "trex_5")!,
                UIImage(named: "trex_6")!,
                UIImage(named: "trex_7")!,
                UIImage(named: "trex_8")!,
                UIImage(named: "trex_9")!,
                UIImage(named: "trex_10")!,
                UIImage(named: "trex_11")!,
                UIImage(named: "trex_12")!,
                UIImage(named: "trex_13")!,
                UIImage(named: "trex_12")!,
                UIImage(named: "trex_11")!,
                UIImage(named: "trex_10")!,
                UIImage(named: "trex_9")!,
                UIImage(named: "trex_8")!,
                UIImage(named: "trex_7")!,
                UIImage(named: "trex_6")!,
                UIImage(named: "trex_5")!,
                UIImage(named: "trex_4")!,
                UIImage(named: "trex_3")!,
                UIImage(named: "trex_2")!
              ],
              heartbeat: 1.8),
        .init(name: String(localized: "マグロ"),
              scientificName: "Thunnus orientalis",
              images: [
                UIImage(named: "tuna_1")!,
                UIImage(named: "tuna_2")!,
                UIImage(named: "tuna_3")!,
                UIImage(named: "tuna_4")!,
                UIImage(named: "tuna_5")!,
                UIImage(named: "tuna_6")!,
                UIImage(named: "tuna_7")!,
                UIImage(named: "tuna_6")!,
                UIImage(named: "tuna_5")!,
                UIImage(named: "tuna_4")!,
                UIImage(named: "tuna_3")!,
                UIImage(named: "tuna_2")!
              ],
              heartbeat: 0.6),
        .init(name: String(localized: "カメ"),
              scientificName: "Mauremys japonica",
              images: [
                UIImage(named: "turtle_1")!,
                UIImage(named: "turtle_2")!,
                UIImage(named: "turtle_3")!,
                UIImage(named: "turtle_4")!,
                UIImage(named: "turtle_5")!,
                UIImage(named: "turtle_6")!,
                UIImage(named: "turtle_7")!,
                UIImage(named: "turtle_8")!,
                UIImage(named: "turtle_9")!,
                UIImage(named: "turtle_10")!,
                UIImage(named: "turtle_11")!,
                UIImage(named: "turtle_12")!,
                UIImage(named: "turtle_13")!,
                UIImage(named: "turtle_12")!,
                UIImage(named: "turtle_11")!,
                UIImage(named: "turtle_10")!,
                UIImage(named: "turtle_9")!,
                UIImage(named: "turtle_8")!,
                UIImage(named: "turtle_7")!,
                UIImage(named: "turtle_6")!,
                UIImage(named: "turtle_5")!,
                UIImage(named: "turtle_4")!,
                UIImage(named: "turtle_3")!,
                UIImage(named: "turtle_2")!
              ],
              heartbeat: 2.6),
        .init(name: String(localized: "クジラ"),
              scientificName: "Balaenoptera musculus",
              images: [
                UIImage(named: "whale_1")!,
                UIImage(named: "whale_2")!,
                UIImage(named: "whale_3")!,
                UIImage(named: "whale_4")!,
                UIImage(named: "whale_5")!,
                UIImage(named: "whale_6")!,
                UIImage(named: "whale_7")!,
                UIImage(named: "whale_8")!,
                UIImage(named: "whale_9")!,
                UIImage(named: "whale_10")!,
                UIImage(named: "whale_11")!,
                UIImage(named: "whale_12")!,
                UIImage(named: "whale_13")!,
                UIImage(named: "whale_14")!,
                UIImage(named: "whale_15")!,
                UIImage(named: "whale_16")!,
                UIImage(named: "whale_15")!,
                UIImage(named: "whale_14")!,
                UIImage(named: "whale_13")!,
                UIImage(named: "whale_12")!,
                UIImage(named: "whale_11")!,
                UIImage(named: "whale_10")!,
                UIImage(named: "whale_9")!,
                UIImage(named: "whale_8")!,
                UIImage(named: "whale_7")!,
                UIImage(named: "whale_6")!,
                UIImage(named: "whale_5")!,
                UIImage(named: "whale_4")!,
                UIImage(named: "whale_3")!,
                UIImage(named: "whale_2")!
              ],
              states: [
                .init(name: String(localized: "安静"), heartbeat: 2.0),
                .init(name: String(localized: "潜水中"), heartbeat: 7.5)
              ]),
        .init(name: String(localized: "ミミズ"),
              scientificName: "Lumbricus terrestris",
              images: [
                UIImage(named: "worm_1")!,
                UIImage(named: "worm_2")!,
                UIImage(named: "worm_3")!,
                UIImage(named: "worm_4")!,
                UIImage(named: "worm_5")!,
                UIImage(named: "worm_6")!,
                UIImage(named: "worm_5")!,
                UIImage(named: "worm_4")!,
                UIImage(named: "worm_3")!,
                UIImage(named: "worm_2")!
              ],
              heartbeat: 2.5),
    ]

    var body: some View {
        GeometryReader { geometry in
            let cellWidth = (geometry.size.width - SpecimenStyle.ruleWidth) / 2
            ZStack {
                SpecimenStyle.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    ScrollView {
                        // 罫線はセルの隙間に重ねて描く。再生中はぐにゃぐにゃ揺らす
                        if isText {
                            LazyVStack(spacing: SpecimenStyle.ruleWidth) {
                                ForEach(Array(creatures.enumerated()), id: \.element) { index, creature in
                                    if let slot = nativeAdSlots[index] {
                                        nativeAdRow(slot: slot)
                                    }
                                    CreatureTextView(number: index + 1,
                                                     creature: creature,
                                                     isMove: isMove)
                                        .onTapGesture { showDetail(index: index) }
                                }
                            }
                            .overlay {
                                WobblyRuleLines(isMove: isMove,
                                                verticalLineXs: [],
                                                rowPitch: CreatureTextView.height + SpecimenStyle.ruleWidth)
                            }
                            .onAppear { nativeAdLoader.load() }
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: SpecimenStyle.ruleWidth),
                                                GridItem(.flexible(), spacing: SpecimenStyle.ruleWidth)],
                                      spacing: SpecimenStyle.ruleWidth) {
                                ForEach(Array(creatures.enumerated()), id: \.element) { index, creature in
                                    // ネイティブ広告も生物と同じマスに置く
                                    if let slot = nativeAdSlots[index] {
                                        nativeAdCell(slot: slot, width: cellWidth)
                                    }
                                    specimenCell(index: index, creature: creature, width: cellWidth)
                                        .onTapGesture { showDetail(index: index) }
                                }
                            }
                            // 末尾までスクロールしたとき、中央の縦線が画面の下端（ホームインジケータの下）まで届くよう余白を足す
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .overlay {
                                WobblyRuleLines(isMove: isMove,
                                                verticalLineXs: [cellWidth + SpecimenStyle.ruleWidth / 2],
                                                rowPitch: cellWidth * 1.12 + SpecimenStyle.ruleWidth,
                                                // イラストのマスは大きいので、文字表示よりはっきり揺らす
                                                amplitude: 4)
                            }
                        }
                    }
                    // 画像表示では下のSafeAreaまでスクロール領域を広げ、縦線を画面の下端まで伸ばす
                    .ignoresSafeArea(.container, edges: isText ? [] : .bottom)
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

    @ViewBuilder
    private func nativeAdCell(slot: Int, width: CGFloat) -> some View {
        Group {
            if let nativeAd = nativeAdLoader.nativeAd(at: slot) {
                NativeAdCellView(nativeAd: nativeAd)
            } else {
                SpecimenStyle.background
            }
        }
        .frame(width: width, height: width * 1.12)
        .onAppear { nativeAdLoader.load() }
    }

    /// 文字表示の行と同じ高さにする。空の行を置くと罫線が二重になるので、読み込めるまでは何も出さない
    @ViewBuilder
    private func nativeAdRow(slot: Int) -> some View {
        if let nativeAd = nativeAdLoader.nativeAd(at: slot) {
            NativeAdRowView(nativeAd: nativeAd)
                .frame(height: CreatureTextView.height)
        }
    }

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
                .accessibilityLabel(isMove ? Text("動きを止める") : Text("動かす"))
                Spacer()
                Button(action: {
                    isText.toggle()
                }) {
                    Image(systemName: isText ? "bolt.heart" : "waveform.path.ecg.rectangle")
                        .font(.system(size: 18, weight: .regular))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(SpecimenStyle.border, lineWidth: 1))
                }
                .accessibilityLabel(isText ? Text("画像表示に切り替える") : Text("文字表示に切り替える"))
            }
            .foregroundColor(SpecimenStyle.ink)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("鼓動標本")
                    .font(SpecimenStyle.mincho(36, bold: true))
                    .tracking(1.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
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

/// 一覧のセルの隙間に引く罫線。再生中は手描きのようにぐにゃぐにゃ揺れ、止めると真っ直ぐに戻る
struct WobblyRuleLines: View {
    let isMove: Bool
    /// 縦線を引くx座標
    let verticalLineXs: [CGFloat]
    /// 横線の間隔（セルの高さ＋罫線の太さ）。セルの下端ごとに引き、一番下には引かない
    let rowPitch: CGFloat
    /// 揺れの大きさ（pt）
    var amplitude: CGFloat = 1.6
    /// 線を折れ線で近似するときの刻み
    private static let step: CGFloat = 4

    var body: some View {
        Group {
            if isMove {
                TimelineView(.animation) { context in
                    canvas(time: context.date.timeIntervalSinceReferenceDate)
                }
            } else {
                canvas(time: nil)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func canvas(time: TimeInterval?) -> some View {
        Canvas { context, size in
            var path = Path()
            for x in verticalLineXs {
                addLine(to: &path, length: size.height, seed: x, time: time) { along, offset in
                    CGPoint(x: x + offset, y: along)
                }
            }
            if rowPitch > 0 {
                var y = rowPitch - SpecimenStyle.ruleWidth / 2
                while y < size.height - rowPitch / 2 {
                    let lineY = y
                    addLine(to: &path, length: size.width, seed: lineY, time: time) { along, offset in
                        CGPoint(x: along, y: lineY + offset)
                    }
                    y += rowPitch
                }
            }
            context.stroke(path, with: .color(SpecimenStyle.rule), lineWidth: SpecimenStyle.ruleWidth)
        }
    }

    private func addLine(to path: inout Path,
                         length: CGFloat,
                         seed: CGFloat,
                         time: TimeInterval?,
                         point: (CGFloat, CGFloat) -> CGPoint) {
        var along: CGFloat = 0
        path.move(to: point(0, offset(along: 0, seed: seed, time: time)))
        while along < length {
            along = min(along + Self.step, length)
            path.addLine(to: point(along, offset(along: along, seed: seed, time: time)))
        }
    }

    /// 波長と速さの違う2つの波を重ねて、規則的すぎない揺れにする。線ごとにseedで位相をずらす
    private func offset(along: CGFloat, seed: CGFloat, time: TimeInterval?) -> CGFloat {
        guard let time else { return 0 }
        let t = CGFloat(time.truncatingRemainder(dividingBy: 10_000))
        let primary = sin(along / 53 + t * 2.1 + seed * 0.37)
        let secondary = sin(along / 23 - t * 3.3 + seed * 0.61)
        return amplitude * (primary * 0.65 + secondary * 0.35)
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

    /// 心臓のない生物（心拍0）は0bpmにする
    static func bpm(_ heartbeat: Double) -> Int {
        guard heartbeat > 0 else { return 0 }
        return Int((60 / heartbeat).rounded())
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
