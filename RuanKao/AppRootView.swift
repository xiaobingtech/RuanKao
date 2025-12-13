//
//  AppRootView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/24.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject private var userPreferences = UserPreferences.shared
    @StateObject private var router = TabRouter()
    
    var body: some View {
        Group {
            if !userPreferences.isLoggedIn {
                // User not logged in - show login view
                LoginView()
            } else if userPreferences.selectedCourseId == nil {
                // User logged in but hasn't selected a course - show course selection
                CourseSelectionView()
            } else {
                // User logged in and has selected a course - show main app
                MainTabView()
            }
        }
        // 确保所有分支（包括 CourseSelectionView 的 fullScreenCover）都能拿到同一个 TabRouter
        .environmentObject(router)
    }
}

#Preview {
    AppRootView()
}
