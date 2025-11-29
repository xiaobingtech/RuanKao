//
//  LoginView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @StateObject private var userPreferences = UserPreferences.shared
    
    var body: some View {
        ZStack {
            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.95, green: 0.97, blue: 1.0),
//                    Color(red: 0.98, green: 0.99, blue: 1.0)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and app name section
                VStack(spacing: 24) {
                    // App Logo
                    Image(systemName: "graduationcap.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.5, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // App Name
                    Text("软考")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Subtitle
                    Text("专业的软件资格考试助手")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 80)
                
                Spacer()
                
                // Sign in with Apple button
                VStack(spacing: 16) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                // Handle successful authentication
                                print("Authorization successful: \(authorization)")
                                
                                // Extract user credentials
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    // Get the user ID from Apple Sign-In
                                    let userId = appleIDCredential.user
                                    
                                    // Generate username: "项网学员" + last 4 digits of user ID
                                    let lastFourDigits = String(userId.suffix(4))
                                    let username = "项网学员\(lastFourDigits)"
                                    
                                    // Save to UserDefaults
                                    userPreferences.setUserData(userId: userId, username: username)
                                    print("Saved user data - User ID: \(userId), Username: \(username)")
                                    
                                    // Save to SwiftData for iCloud sync
                                    let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userId == userId })
                                    do {
                                        let users = try modelContext.fetch(descriptor)
                                        if let existingUser = users.first {
                                            print("User already exists in SwiftData: \(existingUser.userId)")
                                            // Update username if changed
                                            if existingUser.username != username {
                                                existingUser.username = username
                                                try modelContext.save()
                                                print("Updated username for existing user")
                                            }
                                        } else {
                                            let user = User(userId: userId, username: username)
                                            modelContext.insert(user)
                                            try modelContext.save()
                                            print("New user saved to SwiftData successfully")
                                        }
                                    } catch {
                                        print("Failed to handle user data in SwiftData: \(error.localizedDescription)")
                                    }
                                    
                                    // Set login status
                                    userPreferences.login()
                                }
                                
                            case .failure(let error):
                                // Handle authentication error
                                print("Authorization failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Privacy notice
                    Text("登录即表示您同意我们的服务条款和隐私政策")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    LoginView()
}
