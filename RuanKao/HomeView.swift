//
//  HomeView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("首页")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("首页")
        }
    }
}

#Preview {
    HomeView()
}
