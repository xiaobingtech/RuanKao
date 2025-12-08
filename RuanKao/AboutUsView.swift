//
//  AboutUsView.swift
//  RuanKao
//
//  Created on 2025/12/8.
//

import SwiftUI

// MARK: - App Model for API
struct AppItem: Codable, Identifiable {
    let name: String
    let url: String
    let id: Int
    let urlscheme: String
    let icon: String
    let content: String
}

struct AppsResponse: Codable {
    let data: [AppItem]
}

// MARK: - About Us View
struct AboutUsView: View {
    @State private var apps: [AppItem] = []
    @State private var isLoading = true
    @State private var loadError: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. Current App Icon and Name
                VStack(spacing: 12) {
                    // App Icon
                    if let appIcon = Bundle.main.icon {
                        Image(uiImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.blue)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "app.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    
                    // App Name
                    Text(Bundle.main.appName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // App Version
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("版本 \(version)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 32)
                
//                Divider()
//                    .padding(.horizontal)
                
                // 2. Other Apps Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("我们的应用")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else if let error = loadError {
                        HStack {
                            Spacer()
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                    } else {
                        // App List - App Store Style
                        VStack(spacing: 0) {
                            ForEach(apps) { app in
                                AppListItemView(app: app)
                                
                                if app.id != apps.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
                
//                Divider()
//                    .padding(.horizontal)
                
                // 3. ICP Record Number
                VStack(spacing: 8) {
                    Text("鲁ICP备2024080492号-4A")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            if let url = URL(string: "https://beian.miit.gov.cn/") {
                                UIApplication.shared.open(url)
                            }
                        }
                    
                    Text("© 2025 小兵科技")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("关于我们")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadApps()
        }
    }
    
    private func loadApps() {
        guard let url = URL(string: "http://img.app.xiaobingkj.com/apps.json") else {
            loadError = "无效的URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    loadError = "加载失败: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    loadError = "无数据"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AppsResponse.self, from: data)
                    apps = response.data
                } catch {
                    loadError = "解析失败: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - App List Item View (App Store Style)
struct AppListItemView: View {
    let app: AppItem
    
    var body: some View {
        HStack(spacing: 12) {
            // App Icon
            AsyncImage(url: URL(string: app.icon)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "app.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // App Info
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(app.content)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Get Button
            Button(action: {
                if let url = URL(string: app.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("获取")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.15))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Bundle Extension for App Info
extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String
            ?? infoDictionary?["CFBundleName"] as? String
            ?? "RuanKao"
    }
    
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        AboutUsView()
    }
}
