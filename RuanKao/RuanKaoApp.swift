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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
            Purchases.configure(withAPIKey: "test_VjQehAaXggenxFHxkPWazhOdmVQ")
        
            // TestFlight/Release 下如果资源未被正确打包，Firebase 直接 configure 可能触发断言崩溃。
            // 这里改成“可恢复”的配置：找不到 GoogleService-Info.plist 就跳过（不影响基础功能）。
            if FirebaseApp.app() == nil {
                if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                   let options = FirebaseOptions(contentsOfFile: path) {
                    FirebaseApp.configure(options: options)
                } else {
                    print("⚠️ Firebase 未配置：找不到 GoogleService-Info.plist（或内容无效），已跳过 FirebaseApp.configure()")
                }
            }
        }
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [WrongQuestion.self, StudyStatistics.self, User.self])
    }
}
