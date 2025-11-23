//
//  QuestionBankView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct QuestionBankView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("题库")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("题库")
        }
    }
}

#Preview {
    QuestionBankView()
}
