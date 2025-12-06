//
//  RuanKaoApp.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import SwiftData
import RevenueCat
import Firebase

@main
struct RuanKaoApp: App {
    init() {
            Purchases.configure(withAPIKey: "appl_zIaHsxwoBijSDqiLpgXnbwPtChS")
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [WrongQuestion.self, StudyStatistics.self, User.self])
    }
}
