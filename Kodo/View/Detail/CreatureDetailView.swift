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
    @State private var stateIndex: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                let length = min(geometry.size.width, geometry.size.height)
                VStack {
                    closeButton
                    Spacer()
                }
                VStack {
                    ImageSliderView(width: length,
                                    creatures: creatures,
                                    index: $index,
                                    stateIndex: $stateIndex,
                                    timer: $timer)
                    .position(x: length / 2, y: length / 2)
                    .frame(width: length, height: length, alignment: .center)
                    statePicker
                    ProgressView(value: Float(index),total: Float(creatures.count - 1))
                        .progressViewStyle(.linear)
                        .padding()
                }
            }
        }
    }

    @ViewBuilder
    private var statePicker: some View {
        let states = creatures[index].states
        if states.count > 1 {
            Picker("状態", selection: $stateIndex) {
                ForEach(Array(states.enumerated()), id: \.offset) { offset, state in
                    Text(state.name).tag(offset)
                }
            }
            .pickerStyle(.segmented)
            .environment(\.colorScheme, .dark)
            .padding(.horizontal)
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
