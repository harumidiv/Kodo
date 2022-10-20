//
//  CreatureTextView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

struct CreatureTextView: View {
    let creature: Creature
    let length: Double
    var body: some View {
        Text(creature.name)
            .foregroundColor(.red)
            .frame(width: length, height: length)
            .blinkEffect(interval: creature.heartbeat / 2)
    }
}

struct CreatureTextView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureTextView(creature: Creature.sampleData[0],
                         length: 100)
    }
}
