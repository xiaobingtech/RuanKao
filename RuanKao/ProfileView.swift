//
//  ProfileView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import SwiftData
import UIKit
import RevenueCat
import RevenueCatUI
import MessageUI

struct ProfileView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var showLogoutConfirmation = false
    @State private var showMailCompose = false
    
    @State var displayPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Avatar and Nickname Section
                    VStack(spacing: 12) {
                        // Avatar - tappable to edit
                        NavigationLink(destination: EditAvatarView(userPreferences: userPreferences)) {
                            ProfileAvatarView(avatarUrl: userPreferences.avatar)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Nickname - tappable to edit
                        NavigationLink(destination: EditProfileView(userPreferences: userPreferences)) {
                            HStack(spacing: 4) {
                                Text(userPreferences.username ?? "项网学员")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Course Switch Card
                    CourseSwitchCard(userPreferences: userPreferences)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    
                    // Favorites and Settings List
                    VStack(spacing: 16) {
                        // My Favorites Section
                        ProfileListSection(title: "会员") {
                            ProfileListItem(
                                icon: "crown.fill",
                                title: "成为项网会员",
                                iconColor: .orange,
                            ).onTapGesture {
                                displayPaywall = true
                            }
                        }
                        
                        
                        // Settings Section
                        ProfileListSection(title: "设置") {
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileListItem(
                                icon: "envelope.fill",
                                title: "反馈意见",
                                iconColor: .blue
                            )
                            .onTapGesture {
                                if MFMailComposeViewController.canSendMail() {
                                    showMailCompose = true
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            NavigationLink(destination: AboutUsView()) {
                                HStack(spacing: 16) {
                                    // Icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Title
                                    Text("关于我们")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Chevron
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // Logout button - using direct HStack to avoid nested button issues
                            HStack(spacing: 16) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                // Title
                                Text("退出登录")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Chevron
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .onTapGesture {
                                showLogoutConfirmation = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("我的")
            .alert("退出登录", isPresented: $showLogoutConfirmation) {
                Button("取消", role: .cancel) { }
                Button("退出", role: .destructive) {
                    performLogout()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
            .sheet(isPresented: $displayPaywall) {
            // We handle scroll views for you, no need to wrap this in a ScrollView
                PaywallView()
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    recipient: "fandong@xiaobingkj.com",
                    subject: "项网反馈意见",
                    body: "\n\n---\n设备信息：\(UIDevice.current.model) / iOS \(UIDevice.current.systemVersion)"
                )
            }
        }
    }
    
    private func performLogout() {
        // Clear all user data
        userPreferences.clearAll()
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Profile Avatar View
struct ProfileAvatarView: View {
    let avatarUrl: String?
    
    var body: some View {
        Group {
            if let avatarUrlString = avatarUrl,
               let url = URL(string: avatarUrlString) {
                // Display avatar from URL
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderAvatar
                    case .empty:
                        ZStack {
                            placeholderAvatar
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    @unknown default:
                        placeholderAvatar
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            } else {
                // Default placeholder
                placeholderAvatar
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var placeholderAvatar: some View {
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
    }
}

// MARK: - Profile Header Section (Deprecated - kept for reference)
struct ProfileHeaderSection: View {
    let userName: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ProfileAvatarView(avatarUrl: nil)
            
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

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var userPreferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var editedUsername: String = ""
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("昵称")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 60, alignment: .leading)
                    
                    TextField("请输入昵称", text: $editedUsername)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 4)
            } header: {
                Text("个人信息")
            } footer: {
                Text("设置一个您喜欢的昵称")
                    .font(.system(size: 13))
            }
            
            Section {
                Button(action: saveUsername) {
                    HStack {
                        Spacer()
                        Text("保存")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                editedUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray.opacity(0.5)
                                : Color.blue
                            )
                    )
                }
                .disabled(editedUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            editedUsername = userPreferences.username ?? "项网学员"
        }
        .alert("保存成功", isPresented: $showingSaveConfirmation) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("您的昵称已更新")
        }
    }
    
    private func saveUsername() {
        let trimmedUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        // Update UserDefaults
        userPreferences.username = trimmedUsername
        
        // Update SwiftData for iCloud sync
        if let userId = userPreferences.userId {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userId == userId })
            do {
                let users = try modelContext.fetch(descriptor)
                if let existingUser = users.first {
                    existingUser.username = trimmedUsername
                    try modelContext.save()
                    print("Updated username in SwiftData: \(trimmedUsername)")
                } else {
                    print("Warning: User not found in SwiftData for userId: \(userId)")
                }
            } catch {
                print("Failed to update username in SwiftData: \(error.localizedDescription)")
            }
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        showingSaveConfirmation = true
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let recipient: String
    let subject: String
    let body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients([recipient])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}
