//
//  KodoApp.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/19.
//

import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

@main
struct KodoApp: App {
    @State private var isText: Bool = false
    @State private var isMove: Bool = false
    @State private var isAdsStarted: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            KodoListView(isText: $isText, isMove: $isMove)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task { await requestTrackingAndStartAds() }
        }
    }

    /// ATTダイアログはアプリがアクティブな状態でしか表示されないため、active遷移時にリクエストする
    /// 広告リクエストより前に許可状態を確定させるため、ATTの完了後にMobileAdsを開始する
    @MainActor
    private func requestTrackingAndStartAds() async {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }
        guard !isAdsStarted else { return }
        isAdsStarted = true
        MobileAds.shared.start(completionHandler: nil)
    }
}
