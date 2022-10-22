//
//  ImageSliderView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/21.
//

import SwiftUI

struct ImageSliderView: View {
    let creatures: [Creature]
    @Binding var index: Int

    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let length = min(geometry.size.width, geometry.size.height)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(creatures) { creature in
                            Image(uiImage: creature.images.last!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: length, height: length)
                        }
                    }
                }
                .content.offset(x: self.offset)
                .gesture(DragGesture()
                    .onChanged{ value in
                        self.offset = value.translation.width - length * CGFloat(self.index)
                    }
                    .onEnded{ value in
                        let scrollThreshold = length / 2
                        if value.predictedEndTranslation.width < -scrollThreshold {
                            self.index = min(self.index + 1, creatures.endIndex - 1)
                        } else if value.predictedEndTranslation.width > scrollThreshold {
                            self.index = max(self.index - 1, 0)
                        }
                        
                        withAnimation {
                            self.offset = -length * CGFloat(self.index)
                        }
                    }
                )
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation{
                            index -= 1
                            self.offset = -length * CGFloat(self.index)
                        }
                    }) {
                        Image(systemName:"chevron.left")
                            .font(Font.system(size: ConstantValue.fontSize, weight: .regular))
                            .frame(width: ConstantValue.buttonWidth, height: ConstantValue.buttonWidth)
                    }
                    .opacity(index == 0 ? 0.0 : 1.0)
                    
                    Rectangle()
                        .frame(width: length - ConstantValue.buttonWidth * 2)
                        .foregroundColor(.clear)
                    
                    Button(action: {
                        withAnimation{
                            index += 1
                            self.offset = -length * CGFloat(self.index)
                        }
                    }) {
                        Image(systemName:"chevron.right")
                            .font(Font.system(size: ConstantValue.fontSize, weight: .regular))
                            .frame(width: ConstantValue.buttonWidth, height: ConstantValue.buttonWidth)
                    }
                    .opacity(index == creatures.count - 1 ? 0.0 : 1.0)
                    
                    Spacer() // 横幅がでかいのでSpacerで左寄せにする
                }
            }
        }
        .onAppear{

        }
    }
    
    private struct ConstantValue {
        static let buttonWidth: CGFloat = 32
        static let fontSize: CGFloat = 28
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(creatures: Creature.sampleData,
                        index: .constant(0))
    }
}
