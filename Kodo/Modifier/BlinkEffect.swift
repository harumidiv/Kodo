//
//  BlinkEffect.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI

struct BlinkEffect: ViewModifier {
    @State var isOn: Bool = false
    let opacityRange: ClosedRange<Double>
    let interval: Double

    init(opacity: ClosedRange<Double>, interval: Double) {
        self.opacityRange = opacity
        self.interval = interval
    }

    func body(content: Content) -> some View {
        content
            .opacity(self.isOn ? self.opacityRange.lowerBound : self.opacityRange.upperBound)
            .animation(Animation.linear(duration: self.interval).repeatForever())
            .onAppear(perform: {
                self.isOn = true
            })
    }
}

extension View {
    func blinkEffect(opacity: ClosedRange<Double> = 0.1...1, interval: Double = 0.6) -> some View {
        self.modifier(BlinkEffect(opacity: opacity, interval: interval))
    }
}
