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
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // NOP
    }


}
