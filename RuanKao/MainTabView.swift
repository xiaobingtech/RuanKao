//
//  MainTabView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: TabRouter
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(MainTab.home)
            
            QuestionBankView()
                .tabItem {
                    Label("题库", systemImage: "book.fill")
                }
                .tag(MainTab.questionBank)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(MainTab.profile)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(TabRouter())
}
