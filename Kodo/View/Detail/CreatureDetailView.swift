//
//  CreatureDetailView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/21.
//

import SwiftUI

struct CreatureDetailView: View {
    let creatures: [Creature]
    @Binding var isShowDetail: Bool
    @Binding var index: Int

    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                let length = min(geometry.size.width, geometry.size.height)
                VStack {
                    closeButton
                    Spacer()
                }
                VStack(spacing: 0) {
                    ImageSliderView(width: length,
                                    creatures: creatures,
                                    index: $index,
                                    timer: $timer)
                    .position(x: length / 2, y: length / 2)
                    .frame(width: length, height: length, alignment: .center)
                    Text("aaa")
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var closeButton: some View {
        HStack {
            Button(action: {
                timer?.invalidate()
                timer = nil
                isShowDetail.toggle()
            }, label: {
                Image(systemName: "xmark")
                    .font(Font.system(size: 28, weight: .regular))
                    .padding()
            })
            Spacer()
        }
    }
}

struct CreatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureDetailView(creatures: Creature.sampleData,
                           isShowDetail: .constant(true),
                           index: .constant(0))
    }
}
