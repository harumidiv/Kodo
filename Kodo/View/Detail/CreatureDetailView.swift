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
                    ImageSliderView(creatures: creatures,
                                    index: $index,
                                    timer: $timer)
                    .frame(width: length, height: length)
                    .background(.red) // TODO 検証ようなので不要になったら削除
                }
            }
        }
        .onChange(of: index) { index in
            // TODO 切り替わった時にタイマーを止めて表示されている動物の鼓動に変更する
            print("index: \(index)")
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
