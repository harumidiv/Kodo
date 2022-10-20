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

    struct Creature: Identifiable {
        let id: UUID = UUID()
        let name: String
        let images: [UIImage]
        let heartbeat: Double
    }

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
            let length = min(geometry.size.width, geometry.size.height) / 3
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    LazyVGrid(columns: [GridItem(),GridItem(), GridItem()]) {
                        ForEach(creatures) { creature in
                            if isText {
                                Text(creature.name)
                                    .foregroundColor(.red)
                                    .frame(width: length, height: length)
                                    .blinkEffect(interval: creature.heartbeat / 2)
                                Spacer()
                            } else {
                                ParaparaAnimationView(duration: creature.heartbeat, images: creature.images)
                                    .frame(width: length, height: length)
                                    .onTapGesture{
                                        if isTapped {
                                            isTapped = false
                                            timer?.invalidate()
                                            timer = nil
                                        } else {
                                            isTapped = true
                                            timer = Timer.scheduledTimer(withTimeInterval: creature.heartbeat, repeats: true) { _ in
                                                Task {
                                                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                                    impactHeavy.prepare()
                                                    impactHeavy.impactOccurred()
                                                    try await Task.sleep(seconds: creature.heartbeat / 2)
                                                    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
                                                    impactSoft.prepare()
                                                    impactSoft.impactOccurred()
                                                }
                                            }
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
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
