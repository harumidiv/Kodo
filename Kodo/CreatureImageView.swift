//
//  CreatureImageView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

struct CreatureImageView: View {
    let creature: Creature
    let length: Double
    @Binding var timer: Timer?
    @Binding var isTapped: Bool

    var body: some View {
        ParaparaAnimationView(duration: creature.heartbeat,
                              images: creature.images)
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
        .onDisappear{
            timer?.invalidate()
            timer = nil
        }
    }
}

struct CreatureImageView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureImageView(creature: Creature.sampleData[0],
                          length: 100,
                          timer: .constant(nil),
                          isTapped: .constant(false))
    }
}
