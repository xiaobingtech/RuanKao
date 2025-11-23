//
//  ProfileView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("我的")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
}
