//
//  EditAvatarView.swift
//  RuanKao
//
//  Created by fandong on 2025/12/08.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditAvatarView: View {
    @ObservedObject var userPreferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadProgress: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        Form {
            Section {
                // Photo Picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            if let image = selectedImage {
                                // Show selected and cropped image
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            } else if let avatarUrl = userPreferences.avatar,
                                      let url = URL(string: avatarUrl) {
                                // Show current avatar
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        placeholderAvatar
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        placeholderAvatar
                                    }
                                }
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 5)
                            } else {
                                // Show placeholder
                                placeholderAvatar
                                    .frame(width: 150, height: 150)
                            }
                            
                            Text("点击选择图片")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    loadAndCropImage(from: newValue)
                }
            } header: {
                Text("选择头像")
            } footer: {
                Text("从相册中选取图片，将自动裁剪为正方形")
                    .font(.system(size: 13))
            }
            
            Section {
                Button(action: uploadAvatar) {
                    HStack {
                        Spacer()
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                            Text(uploadProgress)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Text("保存")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                (selectedImage == nil || isUploading)
                                ? Color.gray.opacity(0.5)
                                : Color.blue
                            )
                    )
                }
                .disabled(selectedImage == nil || isUploading)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("编辑头像")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .alert("上传失败", isPresented: $showError) {
            Button("确定") {}
        } message: {
            Text(errorMessage)
        }
        .alert("保存成功", isPresented: $showSuccessAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("您的头像已更新")
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
            
            Image(systemName: "person.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private func loadAndCropImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    // Crop to square
                    let croppedImage = cropToSquare(uiImage)
                    await MainActor.run {
                        selectedImage = croppedImage
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    private func cropToSquare(_ image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        
        let sideLength = min(originalWidth, originalHeight)
        let x = (originalWidth - sideLength) / 2
        let y = (originalHeight - sideLength) / 2
        
        let cropRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func uploadAvatar() {
        guard let image = selectedImage else { return }
        
        isUploading = true
        uploadProgress = "上传中..."
        
        S3UploadService.shared.uploadAvatar(image: image) { result in
            isUploading = false
            
            switch result {
            case .success(let url):
                // Update UserPreferences
                userPreferences.avatar = url
                
                // Update SwiftData for iCloud sync
                saveToSwiftData(avatarUrl: url)
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                showSuccessAlert = true
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func saveToSwiftData(avatarUrl: String) {
        if let userId = userPreferences.userId {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userId == userId })
            do {
                let users = try modelContext.fetch(descriptor)
                if let existingUser = users.first {
                    existingUser.avatar = avatarUrl
                    try modelContext.save()
                    print("Updated avatar in SwiftData: \(avatarUrl)")
                } else {
                    print("Warning: User not found in SwiftData for userId: \(userId)")
                }
            } catch {
                print("Failed to update avatar in SwiftData: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditAvatarView(userPreferences: UserPreferences.shared)
    }
}
