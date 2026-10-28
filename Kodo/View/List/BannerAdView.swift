//
//  BannerAdView.swift
//  Kodo
//

import GoogleMobileAds
import SwiftUI

/// 一覧画面の下に固定するAdMobのアダプティブバナー
struct BannerAdView: UIViewRepresentable {
    let adSize: AdSize

    private var adUnitID: String {
        #if DEBUG
        // 開発中に本番の広告を表示・タップしないよう、Googleのテスト用IDを使う
        "ca-app-pub-3940256099942544/2435281174"
        #else
        "ca-app-pub-8522231452310619/4074776603"
        #endif
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // NOP
    }
}
