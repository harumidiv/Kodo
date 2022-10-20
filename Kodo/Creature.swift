//
//  Creature.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

struct Creature: Identifiable {
    let id: UUID = UUID()
    let name: String
    let images: [UIImage]
    let heartbeat: Double
}

extension Creature {
    static let sampleData: [Creature] =
    [
        .init(name: "人間",
              images: [UIImage(named: "human_1")!,
                       UIImage(named: "human_2")!,
                       UIImage(named: "human_3")!,
                       UIImage(named: "human_4")!],
              heartbeat: 0.85)
    ]
}
