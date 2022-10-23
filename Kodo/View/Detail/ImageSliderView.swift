//
//  ImageSliderView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/21.
//

import SwiftUI

struct ImageSliderView: View {
    let width: CGFloat
    let creatures: [Creature]
    @Binding var index: Int
    @Binding var timer: Timer?

    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let length = min(geometry.size.width, geometry.size.height)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(creatures) { creature in
                            ParaparaAnimationView(duration: creature.heartbeat,
                                                  images: creature.images)
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

                        // 閾値に到達しなかった場合
                        withAnimation {
                            self.offset = -length * CGFloat(self.index)
                        }
                    }
                )
                HStack(spacing: 0) {
                    leftButton(length: length)
                    scrollSpacer(length: length)
                    rightButton(length: length)
                    Spacer() // 横幅がでかいのでSpacerで左寄せにする
                }
            }
        }
        .onChange(of: index) { index in
            setupTimer(index: index)
        }
        .onAppear{
            offset = -width * CGFloat(self.index)
            setupTimer(index: index)
        }
    }

    // MARK: - View Component

    private func scrollSpacer(length: CGFloat) -> some View {
        Rectangle()
            .frame(width: length - ConstantValue.buttonWidth * 2 - ConstantValue.buttonPadding * 4)
            .foregroundColor(.clear)
    }

    private func leftButton(length: CGFloat) -> some View {
        Button(action: {
            withAnimation{
                index -= 1
                self.offset = -length * CGFloat(self.index)
            }
        }) {
            Image(systemName:"chevron.left")
                .font(Font.system(size: ConstantValue.fontSize, weight: .regular))
                .frame(width: ConstantValue.buttonWidth, height: ConstantValue.buttonWidth)
                .padding(ConstantValue.buttonPadding)
        }
        .opacity(index == 0 ? 0.0 : 1.0)
    }

    private func rightButton(length: CGFloat) -> some View {
        Button(action: {
            withAnimation{
                index += 1
                self.offset = -length * CGFloat(self.index)
            }
        }) {
            Image(systemName:"chevron.right")
                .font(Font.system(size: ConstantValue.fontSize, weight: .regular))
                .frame(width: ConstantValue.buttonWidth, height: ConstantValue.buttonWidth)
                .padding(ConstantValue.buttonPadding)
        }
        .opacity(index == creatures.count - 1 ? 0.0 : 1.0)
    }

    // MARK: - Private Method

    private func setupTimer(index: Int) {
        timer?.invalidate()
        let heartbeat = creatures[index].heartbeat
        timer = Timer.scheduledTimer(withTimeInterval: heartbeat, repeats: true) { _ in
            Task {
                let impactHeavy = await UIImpactFeedbackGenerator(style: .heavy)
                await impactHeavy.prepare()
                await impactHeavy.impactOccurred()
                try await Task.sleep(seconds: heartbeat / 2)
                let impactSoft = await UIImpactFeedbackGenerator(style: .soft)
                await impactSoft.prepare()
                await impactSoft.impactOccurred()
            }
        }
    }
    
    private struct ConstantValue {
        static let buttonWidth: CGFloat = 32
        static let buttonPadding: CGFloat = 16
        static let fontSize: CGFloat = 28
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(width: 375,
                        creatures: Creature.sampleData,
                        index: .constant(0),
                        timer: .constant(nil))
    }
}
