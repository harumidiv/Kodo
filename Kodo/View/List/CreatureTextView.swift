//
//  CreatureTextView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI

/// 文字表示のときの1行。名前と心電図と心拍数を心拍モニターのように並べる
/// 心電図は動きの切り替えに関係なく常に動かす
struct CreatureTextView: View {
    let number: Int
    let creature: Creature

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("No.\(SpecimenStyle.number(number))")
                    .font(SpecimenStyle.mono(10))
                    .tracking(0.8)
                    .foregroundColor(SpecimenStyle.muted)
                Text(creature.name)
                    .font(SpecimenStyle.mincho(17))
                    .tracking(1.2)
                    .foregroundColor(SpecimenStyle.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 84, alignment: .leading)

            ElectrocardiogramView(heartbeat: creature.heartbeat, isMove: true)
                .frame(height: 40)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(SpecimenStyle.bpm(creature.heartbeat))")
                    .font(SpecimenStyle.mono(22))
                    .foregroundColor(SpecimenStyle.heart)
                    .monospacedDigit()
                Text("bpm")
                    .font(SpecimenStyle.mono(10))
                    .foregroundColor(SpecimenStyle.muted)
            }
            .frame(width: 76, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .frame(height: 76)
        .background(SpecimenStyle.background)
        .contentShape(Rectangle())
    }
}

/// 右端が「いま」で、左へ流れていく心電図
struct ElectrocardiogramView: View {
    let heartbeat: Double
    let isMove: Bool
    /// 画面の幅に表示する秒数
    var windowSeconds: Double = 1.5
    var lineWidth: CGFloat = 1.4

    var body: some View {
        if isMove {
            TimelineView(.animation) { context in
                canvas(now: context.date.timeIntervalSinceReferenceDate)
            }
        } else {
            canvas(now: 0)
        }
    }

    private func canvas(now: TimeInterval) -> some View {
        Canvas { context, size in
            let path = tracePath(size: size, now: now)
            // 古い波ほど薄くして、モニターの残像のように見せる
            context.stroke(path,
                           with: .linearGradient(Gradient(colors: [SpecimenStyle.heart.opacity(0.15), SpecimenStyle.heart]),
                                                 startPoint: .zero,
                                                 endPoint: CGPoint(x: size.width, y: 0)),
                           style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
            let radius = lineWidth * 1.8
            let head = CGPoint(x: size.width - radius, y: y(at: now, size: size))
            context.fill(Path(ellipseIn: CGRect(x: head.x - radius, y: head.y - radius, width: radius * 2, height: radius * 2)),
                         with: .color(SpecimenStyle.heart))
        }
    }

    private func tracePath(size: CGSize, now: TimeInterval) -> Path {
        var path = Path()
        let step: CGFloat = 1
        var x: CGFloat = 0
        while x <= size.width {
            let time = now - Double((size.width - x) / size.width) * windowSeconds
            let point = CGPoint(x: x, y: y(at: time, size: size))
            if x == 0 { path.move(to: point) } else { path.addLine(to: point) }
            x += step
        }
        return path
    }

    /// 1拍ぶんの波形（P波・QRS・T波を簡略化したもの）を、拍の間隔で繰り返す
    private func y(at time: TimeInterval, size: CGSize) -> CGFloat {
        let baseline = size.height * 0.6
        let amplitude = size.height * 0.55
        let spikeDuration = min(0.25, heartbeat * 0.8)
        let phase = time.truncatingRemainder(dividingBy: heartbeat)
        let u = (phase < 0 ? phase + heartbeat : phase) / spikeDuration
        guard u < 1 else { return baseline }
        let shape: [(Double, Double)] = [(0, 0), (0.2, -0.2), (0.35, 0.25), (0.5, -1), (0.65, 0.55), (1, 0)]
        for i in 1..<shape.count where u <= shape[i].0 {
            let (u0, v0) = shape[i - 1], (u1, v1) = shape[i]
            let v = v0 + (v1 - v0) * (u - u0) / (u1 - u0)
            return baseline + CGFloat(v) * amplitude
        }
        return baseline
    }
}

struct CreatureTextView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureTextView(number: 1,
                         creature: Creature.sampleData[0])
    }
}
