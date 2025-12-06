//
//  LoginView.swift
//  m3u8Downloader
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import AuthenticationServices
import SwiftData
internal import Combine

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var isAgreed = false
    @State private var showToast = false
    @State private var toastTask: DispatchWorkItem?
    @StateObject private var signInCoordinator = AppleSignInCoordinator()
    
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
                    Text("项网")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Subtitle
                    Text("一个专业的软考助手")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 80)
                
                Spacer()
                
                // Sign in with Apple button
                VStack(spacing: 16) {
                    // Custom button
                    Button(action: {
                        // Check if user agreed to terms
                        guard isAgreed else {
                            // Cancel any existing toast task
                            toastTask?.cancel()
                            
                            // Show toast with animation
                            withAnimation {
                                showToast = true
                            }
                            
                            // Create new task to hide toast
                            let task = DispatchWorkItem {
                                withAnimation {
                                    showToast = false
                                }
                            }
                            toastTask = task
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
                            return
                        }
                        
                        // Trigger Apple login
                        signInCoordinator.handleSignIn { result in
                            switch result {
                            case .success(let authorization):
                                // Handle successful authentication
                                print("Authorization successful: \(authorization)")
                                
                                // Extract user credentials
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    // Get the user ID from Apple Sign-In
                                    let userId = appleIDCredential.user
                                    
                                    // Check if user exists in SwiftData (iCloud)
                                    let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userId == userId })
                                    do {
                                        let users = try modelContext.fetch(descriptor)
                                        
                                        let finalUsername: String
                                        if let existingUser = users.first {
                                            // Existing user: use the saved username from SwiftData (may have been modified by user)
                                            finalUsername = existingUser.username
                                            print("Existing user found, using saved username: \(finalUsername)")
                                        } else {
                                            // New user: generate default username
                                            let lastFourDigits = String(userId.suffix(4))
                                            finalUsername = "项网学员\(lastFourDigits)"
                                            
                                            // Save new user to SwiftData
                                            let user = User(userId: userId, username: finalUsername)
                                            modelContext.insert(user)
                                            try modelContext.save()
                                            print("New user created with username: \(finalUsername)")
                                        }
                                        
                                        // Save to UserDefaults
                                        userPreferences.setUserData(userId: userId, username: finalUsername)
                                        print("Saved user data - User ID: \(userId), Username: \(finalUsername)")
                                        
                                        // Set login status
                                        userPreferences.login()
                                    } catch {
                                        print("Failed to handle user data in SwiftData: \(error.localizedDescription)")
                                    }
                                }
                                
                            case .failure(let error):
                                // Handle authentication error
                                print("Authorization failed: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Sign in with Apple")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Privacy notice with checkbox
                    HStack(alignment: .center, spacing: 5) {
                        Button(action: {
                            isAgreed.toggle()
                        }) {
                            Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                                .font(.system(size: 13))
                                .foregroundColor(isAgreed ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack(spacing: 0) {
                            Text("同意我们的")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Link("服务条款", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            
                            Text("和")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Link("隐私政策", destination: URL(string: "https://xiang.app.xiaobingkj.com/privacy.html")!)
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
            
            // Toast notification
            if showToast {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text("请先同意我们的服务条款和隐私政策")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 200)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// Coordinator to handle Apple Sign In
class AppleSignInCoordinator: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var completion: ((Result<ASAuthorization, Error>) -> Void)?
    
    func handleSignIn(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion?(.success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

#Preview {
    LoginView()
}
