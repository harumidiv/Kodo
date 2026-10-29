//
//  NativeAdCellView.swift
//  Kodo
//

import GoogleMobileAds
import SwiftUI
import UIKit

/// 一覧に出すネイティブ広告を読み込む
@MainActor
final class NativeAdLoader: NSObject, ObservableObject, NativeAdLoaderDelegate {
    @Published private(set) var nativeAd: NativeAd?
    private var adLoader: AdLoader?

    private var adUnitID: String {
        #if DEBUG
        // 開発中に本番の広告を表示・タップしないよう、Googleのテスト用IDを使う
        "ca-app-pub-3940256099942544/3986624511"
        #else
        "ca-app-pub-8522231452310619/2802057537"
        #endif
    }

    func load() {
        guard adLoader == nil else { return }
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        let loader = AdLoader(adUnitID: adUnitID,
                              rootViewController: rootViewController,
                              adTypes: [.native],
                              options: nil)
        loader.delegate = self
        loader.load(Request())
        adLoader = loader
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        // 読み込めなかったときは空きマスのままにする
    }
}

/// 標本マスと同じ見た目のネイティブ広告
struct NativeAdCellView: UIViewRepresentable {
    let nativeAd: NativeAd

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()
        adView.backgroundColor = UIColor(SpecimenStyle.background)

        let adLabel = NativeAdStyle.adLabel(fontSize: 11)
        let callToActionButton = NativeAdStyle.callToActionButton()

        // AdMobの推奨どおり、メディアは120×120pt以上にする
        let mediaView = MediaView()
        mediaView.contentMode = .scaleAspectFit

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont(name: "HiraMinProN-W3", size: 13) ?? .systemFont(ofSize: 13)
        headlineLabel.textColor = UIColor(SpecimenStyle.ink)
        headlineLabel.numberOfLines = 2
        // 高さが足りないときは見出しを1行に縮める
        headlineLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let topRow = UIStackView(arrangedSubviews: [adLabel, UIView(), callToActionButton])
        topRow.alignment = .center
        topRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [topRow, mediaView, headlineLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -14),
            mediaView.heightAnchor.constraint(equalToConstant: 120)
        ])

        adView.headlineView = headlineLabel
        adView.mediaView = mediaView
        adView.callToActionView = callToActionButton
        return adView
    }

    func updateUIView(_ adView: NativeAdView, context: Context) {
        NativeAdStyle.bind(nativeAd, to: adView)
    }
}

/// 文字表示の行と同じ高さ・並びのネイティブ広告
/// 行の高さにメディアが収まらないので、Googleの小さいテンプレートと同じくアイコンと見出しで見せる
struct NativeAdRowView: UIViewRepresentable {
    let nativeAd: NativeAd

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()
        adView.backgroundColor = UIColor(SpecimenStyle.background)

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 6

        let adLabel = NativeAdStyle.adLabel(fontSize: 10)

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont(name: "HiraMinProN-W3", size: 15) ?? .systemFont(ofSize: 15)
        headlineLabel.textColor = UIColor(SpecimenStyle.ink)
        headlineLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [adLabel, headlineLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        let callToActionButton = NativeAdStyle.callToActionButton()
        callToActionButton.setContentHuggingPriority(.required, for: .horizontal)
        callToActionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [iconView, textStack, callToActionButton])
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44)
        ])

        adView.iconView = iconView
        adView.headlineView = headlineLabel
        adView.callToActionView = callToActionButton
        return adView
    }

    func updateUIView(_ adView: NativeAdView, context: Context) {
        NativeAdStyle.bind(nativeAd, to: adView)
    }
}

/// マスと行で共通の、広告の部品と表示内容の設定
private enum NativeAdStyle {
    static func adLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = String(localized: "広告")
        label.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        label.textColor = UIColor(SpecimenStyle.muted)
        return label
    }

    static func callToActionButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10)
        configuration.baseForegroundColor = UIColor(SpecimenStyle.ink)
        configuration.background.strokeColor = UIColor(SpecimenStyle.border)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 11
        let button = UIButton(configuration: configuration)
        // タップはNativeAdViewが受け取るので、ボタン自身は操作を受けない
        button.isUserInteractionEnabled = false
        return button
    }

    static func bind(_ nativeAd: NativeAd, to adView: NativeAdView) {
        guard adView.nativeAd !== nativeAd else { return }
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        adView.mediaView?.mediaContent = nativeAd.mediaContent
        if let iconView = adView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
            iconView.isHidden = nativeAd.icon == nil
        }
        if let button = adView.callToActionView as? UIButton {
            var title = AttributedString(nativeAd.callToAction ?? "")
            title.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            button.configuration?.attributedTitle = title
            button.isHidden = nativeAd.callToAction == nil
        }
        // 最後に設定すると、登録したビューがタップできるようになる
        adView.nativeAd = nativeAd
    }
}
