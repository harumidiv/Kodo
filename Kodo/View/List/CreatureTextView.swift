//
//  CreatureTextView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

struct CreatureTextView: View {
    @Binding var isMove: Bool
    let creature: Creature
    let length: Double
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: length, height: length)
                .foregroundColor(.clear)
                .contentShape(Rectangle())
            if isMove {
                Text(creature.name)
                    .foregroundColor(.red)
                    .frame(width: length, height: length)
                    .blinkEffect(interval: creature.heartbeat / 2)
            } else {
                Text(creature.name)
                    .foregroundColor(.red)
                    .frame(width: length, height: length)
            }
        }
    }
}

struct CreatureTextView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureTextView(isMove: .constant(true),
                         creature: Creature.sampleData[0],
                         length: 100)
    }
}
