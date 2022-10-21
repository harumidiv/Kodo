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
        GeometryReader { geometry in // 1. offset(scroll位置)を操作するため、GeometryReaderを利用
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
            .content.offset(x: self.offset) // 2. self.offsetとscrollViewのoffsetをバインディング
            .frame(width: length,
                   height: nil,
                   alignment: .leading)
            .gesture(DragGesture()
                .onChanged({ value in  // 3. Dragを監視。Dragに合わせて、スクロールする。
                    self.offset = value.translation.width - geometry.size.width * CGFloat(self.index)
                })
                    .onEnded({ value in // 4. Dragが完了したら、Drag量に応じて、indexを更新
                        let scrollThreshold = geometry.size.width / 2
                        if value.predictedEndTranslation.width < -scrollThreshold {
                            self.index = min(self.index + 1, self.imageNames.endIndex - 1)
                        } else if value.predictedEndTranslation.width > scrollThreshold {
                            self.index = max(self.index - 1, 0)
                        }

                        withAnimation { // 5. 更新したindexの画像をアニメーションしながら表示する。
                            self.offset = -geometry.size.width * CGFloat(self.index)
                        }
                    })
            )
        }
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView()
    }
}
