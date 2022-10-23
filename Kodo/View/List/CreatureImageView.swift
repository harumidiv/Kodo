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
    @Binding var isMove: Bool

    var body: some View {
        if isMove {
            ParaparaAnimationView(duration: creature.heartbeat,
                                  images: creature.images)
            .frame(width: length, height: length)
        } else {
            Image(uiImage: creature.images.last!)
                .resizable()
                .scaledToFit()
                .frame(width: length, height: length)
        }

    }
}

struct CreatureImageView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureImageView(creature: Creature.sampleData[0],
                          length: 100,
                          isMove: .constant(false))
    }
}
