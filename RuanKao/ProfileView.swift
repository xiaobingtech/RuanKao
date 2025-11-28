//
//  ProfileView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Avatar and Nickname Section
                    ProfileHeaderSection(
                        userName: userPreferences.username ?? "项网学员"
                    )
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    
                    // Course Switch Card
                    CourseSwitchCard(userPreferences: userPreferences)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    
                    // Favorites and Settings List
                    VStack(spacing: 16) {
                        // My Favorites Section
                        ProfileListSection(title: "我的收藏") {
                            ProfileListItem(
                                icon: "star.fill",
                                title: "收藏的题目",
                                iconColor: .orange,
                                badgeCount: 23
                            )
                        }
                        
                        // Settings Section
                        ProfileListSection(title: "设置") {
                            ProfileListItem(
                                icon: "bell.fill",
                                title: "消息通知",
                                iconColor: .red
                            )
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileListItem(
                                icon: "questionmark.circle.fill",
                                title: "帮助与反馈",
                                iconColor: .blue
                            )
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileListItem(
                                icon: "info.circle.fill",
                                title: "关于我们",
                                iconColor: .gray
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("我的")
        }
    }
}

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    let userName: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.4, blue: 0.9),
                                Color(red: 0.5, green: 0.3, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Nickname
            Text(userName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Profile List Section
struct ProfileListSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Title
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            // Section Content
            VStack(spacing: 0) {
                content
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Profile List Item
struct ProfileListItem: View {
    let icon: String
    let title: String
    let iconColor: Color
    var badgeCount: Int? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle navigation
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Badge Count (if available)
                if let count = badgeCount {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color(UIColor.secondarySystemGroupedBackground)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    ProfileView()
}

// MARK: - Course Switch Card
struct CourseSwitchCard: View {
    @ObservedObject var userPreferences: UserPreferences
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if userPreferences.isAdvancedCourse {
                    userPreferences.selectIntermediateCourse()
                } else {
                    userPreferences.selectAdvancedCourse()
                }
            }
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("当前课程")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(userPreferences.courseDisplayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("切换")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
