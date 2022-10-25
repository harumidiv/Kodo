//
//  HeartbeatEffect.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/25.
//

import SwiftUI

struct HeartbeatEffect: ViewModifier {
    @State var isOn: Bool = false
    let opacityRange: ClosedRange<Double>
    let scaleRange: ClosedRange<Double>
    let interval: Double

    init(opacity: ClosedRange<Double>,
         scale: ClosedRange<Double>,
         interval: Double) {
        self.opacityRange = opacity
        self.scaleRange = scale
        self.interval = interval
    }

    func body(content: Content) -> some View {
        content
            .opacity(self.isOn ? self.opacityRange.lowerBound : self.opacityRange.upperBound)
            .scaleEffect(self.isOn ? self.scaleRange.upperBound : self.scaleRange.lowerBound)
            .animation(.linear(duration: self.interval).repeatForever(), value: isOn)
            .onAppear(perform: {
                self.isOn = true
            })
    }
}
extension View {
    func heartbeatEffect(opacity: ClosedRange<Double> = 0.1...1,
                         scale: ClosedRange<Double> = 0.5...2.0,
                         interval: Double = 0.6) -> some View {
        self.modifier(HeartbeatEffect(opacity: opacity,
                                      scale: scale,
                                      interval: interval))
    }
}
