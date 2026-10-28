//
//  NativeAdCellView.swift
//  Kodo
//

import GoogleMobileAds
import SwiftUI
import UIKit

/// 一覧グリッドの空きマスに出すネイティブ広告を読み込む
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

        let adLabel = UILabel()
        adLabel.text = String(localized: "広告")
        adLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        adLabel.textColor = UIColor(SpecimenStyle.muted)

        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10)
        buttonConfiguration.baseForegroundColor = UIColor(SpecimenStyle.ink)
        buttonConfiguration.background.strokeColor = UIColor(SpecimenStyle.border)
        buttonConfiguration.background.strokeWidth = 1
        buttonConfiguration.background.cornerRadius = 11
        let callToActionButton = UIButton(configuration: buttonConfiguration)
        // タップはNativeAdViewが受け取るので、ボタン自身は操作を受けない
        callToActionButton.isUserInteractionEnabled = false

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
        guard adView.nativeAd !== nativeAd else { return }
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        adView.mediaView?.mediaContent = nativeAd.mediaContent
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
