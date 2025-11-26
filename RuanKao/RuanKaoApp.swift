//
//  RuanKaoApp.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import SwiftData

@main
struct RuanKaoApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [WrongQuestion.self, StudyStatistics.self])
    }
}
