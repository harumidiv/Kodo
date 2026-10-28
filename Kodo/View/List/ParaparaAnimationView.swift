//
//  ParaparaAnimationView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

import SwiftUI
import UIKit

struct ParaparaAnimationView: UIViewRepresentable {
    let duration: Double
    let images: [UIImage]
    typealias UIViewType = UIImageView

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let animateImage = UIImage.animatedImage(with: images, duration: duration)
        imageView.image = animateImage
        context.coordinator.duration = duration
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // ドラッグ中なども呼ばれるので、心拍が変わったときだけアニメーションを作り直す
        guard context.coordinator.duration != duration else { return }
        uiView.image = UIImage.animatedImage(with: images, duration: duration)
        context.coordinator.duration = duration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var duration: Double?
    }
}
