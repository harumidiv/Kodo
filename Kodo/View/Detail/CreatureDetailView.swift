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
    @State private var stateIndex: Int = Int(ProcessInfo.processInfo.environment["SS_STATE"] ?? "") ?? 0

    private var creature: Creature {
        creatures[index]
    }

    private var heartbeat: Double {
        creature.states[min(stateIndex, creature.states.count - 1)].heartbeat
    }

    var body: some View {
        GeometryReader { geometry in
            // 折りたたみを開いた画面などでも数値と状態の切り替えが収まるよう、画像は高さの半分までにする
            let length = min(geometry.size.width, geometry.size.height * 0.5)
            ZStack {
                SpecimenStyle.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    topBar
                    title
                    SpecimenStyle.rule
                        .frame(height: SpecimenStyle.ruleWidth)
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                    ImageSliderView(width: length,
                                    creatures: creatures,
                                    index: $index,
                                    stateIndex: $stateIndex,
                                    timer: $timer)
                    .position(x: length / 2, y: length / 2)
                    .frame(width: length, height: length)
                    .clipped()
                    .frame(maxWidth: .infinity)
                    SpecimenStyle.rule
                        .frame(height: SpecimenStyle.ruleWidth)
                        .padding(.horizontal, 24)
                    stats
                    statePicker
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - View Component

    private var topBar: some View {
        HStack {
            Button(action: {
                timer?.invalidate()
                timer = nil
                isShowDetail.toggle()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(SpecimenStyle.border, lineWidth: 1))
            }
            .foregroundColor(SpecimenStyle.ink)
            .accessibilityLabel("閉じる")
            Spacer()
            Text("No.\(SpecimenStyle.number(index + 1)) / \(SpecimenStyle.number(creatures.count))")
                .font(SpecimenStyle.mono(11))
                .tracking(1.8)
                .foregroundColor(SpecimenStyle.muted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(creature.scientificName.uppercased())
                .font(SpecimenStyle.mono(11))
                .tracking(1.8)
                .foregroundColor(SpecimenStyle.muted)
            Text(creature.name)
                .font(SpecimenStyle.mincho(32, bold: true))
                .tracking(2)
                .foregroundColor(SpecimenStyle.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var stats: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                statItem(label: "心拍数",
                         value: "\(SpecimenStyle.bpm(heartbeat))",
                         unit: "bpm",
                         color: SpecimenStyle.heart)
                SpecimenStyle.rule.frame(width: SpecimenStyle.ruleWidth)
                statItem(label: "1拍の間隔",
                         value: String(format: "%.2f", heartbeat),
                         unit: "秒",
                         color: SpecimenStyle.ink)
                    .padding(.leading, 16)
            }
            .fixedSize(horizontal: false, vertical: true)
            SpecimenStyle.rule.frame(height: SpecimenStyle.ruleWidth)
        }
        .padding(.horizontal, 24)
    }

    private func statItem(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(SpecimenStyle.mono(10))
                .tracking(1.6)
                .foregroundColor(SpecimenStyle.muted)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(SpecimenStyle.mincho(40, bold: true))
                    .foregroundColor(color)
                    .monospacedDigit()
                Text(unit)
                    .font(SpecimenStyle.mincho(13))
                    .foregroundColor(SpecimenStyle.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
    }

    private var statePicker: some View {
        HStack(spacing: 8) {
            // 状態が1つの生物は切り替えを出さないが、高さは揃えておく
            if creature.states.count > 1 {
                ForEach(Array(creature.states.enumerated()), id: \.offset) { offset, state in
                    let isSelected = offset == stateIndex
                    Button(action: {
                        stateIndex = offset
                    }) {
                        Text(state.name)
                            .font(SpecimenStyle.mincho(15))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundColor(isSelected ? SpecimenStyle.background : SpecimenStyle.ink)
                            .background(isSelected ? SpecimenStyle.ink : Color.clear)
                            .overlay(Rectangle().stroke(isSelected ? SpecimenStyle.ink : SpecimenStyle.border, lineWidth: 1))
                    }
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            } else {
                Color.clear.frame(height: 44)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

struct CreatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureDetailView(creatures: Creature.sampleData,
                           isShowDetail: .constant(true),
                           index: .constant(0))
    }
}
