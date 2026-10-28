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
                nameText
                    .blinkEffect(interval: creature.heartbeat / 2)
            } else {
                nameText
            }
        }
    }

    private var nameText: some View {
        Text(creature.name)
            .font(SpecimenStyle.mincho(length * 0.22, bold: true))
            .tracking(length * 0.02)
            .foregroundColor(SpecimenStyle.heart)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(width: length, height: length)
    }
}

struct CreatureTextView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureTextView(isMove: .constant(true),
                         creature: Creature.sampleData[0],
                         length: 100)
    }
}
