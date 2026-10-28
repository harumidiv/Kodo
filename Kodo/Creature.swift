//
//  Creature.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

struct Creature: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    /// 詳細画面に表示する学名
    let scientificName: String
    let images: [UIImage]
    /// 先頭が通常時の状態。2つ以上ある場合のみ詳細画面で切り替えられる
    let states: [HeartbeatState]

    var heartbeat: Double {
        states[0].heartbeat
    }

    init(name: String, scientificName: String, images: [UIImage], heartbeat: Double) {
        self.init(name: name, scientificName: scientificName, images: images, states: [.init(name: String(localized: "安静"), heartbeat: heartbeat)])
    }

    init(name: String, scientificName: String, images: [UIImage], states: [HeartbeatState]) {
        precondition(!states.isEmpty)
        self.name = name
        self.scientificName = scientificName
        self.images = images
        self.states = states
    }
}

struct HeartbeatState: Hashable {
    let name: String
    let heartbeat: Double
}

extension Creature {
    static let sampleData: [Creature] =
    [
        .init(name: String(localized: "人間"),
              scientificName: "Homo sapiens",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85)
    ]
}
