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
        }
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView()
    }
}
