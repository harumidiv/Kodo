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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                let length = min(geometry.size.width, geometry.size.height)
                VStack {
                    closeButton
                    ImageSliderView(creatures: creatures, index: $index)
                        .frame(width: length, height: length)
                        .background(.red) // TODO 検証ようなので不要になったら削除
                }
            }
        }

    }

    private var closeButton: some View {
        HStack {
            Button(action: {
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
