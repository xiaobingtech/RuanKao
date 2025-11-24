//
//  CourseSelectionView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct CourseSelectionView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var selectedCourse: CourseType? = nil
    @State private var navigateToMain = false
    
    enum CourseType: String {
        case advanced = "信息系统项目管理师"
        case intermediate = "系统集成项目管理工程师"
        
        var displayName: String {
            switch self {
            case .advanced:
                return "高项"
            case .intermediate:
                return "中项"
            }
        }
        
        var fullName: String {
            return self.rawValue
        }
        
        var courseId: Int {
            switch self {
            case .advanced:
                return 3  // 高项
            case .intermediate:
                return 4  // 中项
            }
        }
        
        var icon: String {
            switch self {
            case .advanced:
                return "star.fill"
            case .intermediate:
                return "star.leadinghalf.filled"
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .advanced:
                return [
                    Color(red: 0.3, green: 0.4, blue: 0.9),
                    Color(red: 0.5, green: 0.3, blue: 0.8)
                ]
            case .intermediate:
                return [
                    Color(red: 0.2, green: 0.7, blue: 0.9),
                    Color(red: 0.3, green: 0.5, blue: 0.8)
                ]
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.circle.fill")
                            .font(.system(size: 60))
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
                        
                        Text("选择您的课程")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("请选择您要学习的软考科目")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // Course Cards
                    VStack(spacing: 20) {
                        // Advanced Course Card
                        CourseCard(
                            courseType: .advanced,
                            isSelected: selectedCourse == .advanced
                        ) {
                            selectedCourse = .advanced
                            // Save course selection
                            userPreferences.selectAdvancedCourse()
                            // Delay navigation slightly for better UX
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToMain = true
                            }
                        }
                        
                        // Intermediate Course Card
                        CourseCard(
                            courseType: .intermediate,
                            isSelected: selectedCourse == .intermediate
                        ) {
                            selectedCourse = .intermediate
                            // Save course selection
                            userPreferences.selectIntermediateCourse()
                            // Delay navigation slightly for better UX
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToMain = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $navigateToMain) {
                MainTabView()
            }
        }
    }
}

// Course Card Component
struct CourseCard: View {
    let courseType: CourseSelectionView.CourseType
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Icon and Title Section
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: courseType.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: courseType.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Text Content
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(courseType.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Text(courseType.fullName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? 
                            LinearGradient(
                                colors: courseType.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                colors: [Color.clear, Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    CourseSelectionView()
}
