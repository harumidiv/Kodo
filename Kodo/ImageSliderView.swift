//
//  ImageSliderView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/21.
//

import SwiftUI

struct ImageSliderView: View {
    var imageNames: [String] = ["human_1", "human_2", "human_3"]

    @State private var index: Int = 0
    @State private var offset: CGFloat = 0
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let length = min(geometry.size.width, geometry.size.height)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<self.imageNames.count) {
                            Image(self.imageNames[$0])
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
                            self.index = min(self.index + 1, self.imageNames.endIndex - 1)
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
                    .disabled(index == 0)

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
                    .disabled(index == imageNames.count)

                    Spacer() // ScrollViewがいて横幅がでかいのでSpacerで左寄せにする
                }
            }
        }
    }

    private struct ConstantValue {
        static let buttonWidth: CGFloat = 32
        static let fontSize: CGFloat = 28
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView()
    }
}
