//
//  KodoListView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import SwiftUI
import UIKit

struct KodoListView: View {
    @State var timer :Timer?
    @State var isTapped: Bool = false

    var body: some View {
        ZStack {
            Color.black
            ParaparaAnimationView(duration: 0.85, images: [UIImage(named: "human_1")!,
                                                           UIImage(named: "human_2")!,
                                                           UIImage(named: "human_3")!,
                                                           UIImage(named: "human_4")!])
            .frame(width: 200, height: 200)
        }
    }
}

struct KodoListView_Previews: PreviewProvider {
    static var previews: some View {
        KodoListView()
    }
}




//            Button(action: {
//                isTapped = true
//                //人間
//                timer = Timer.scheduledTimer(withTimeInterval: 0.85, repeats: true) { _ in
//                    Task {
//                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
//                        impactHeavy.prepare()
//                        impactHeavy.impactOccurred()
//                        try await Task.sleep(nanoseconds: 400_000_000)
//                        let impactSoft = UIImpactFeedbackGenerator(style: .soft)
//                        impactSoft.prepare()
//                        impactSoft.impactOccurred()
//                    }
//                }
//
//            }, label: {
//                if isTapped {
//                    Text("人間の心臓")
//                        .padding()
//                        .blinkEffect(interval: 0.425)
//                } else {
//                    Text("人間の心臓")
//                        .padding()
//
//                }
//            })
