//
//  QuestionBankView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI

struct QuestionBankView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var navigateToChapters = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Chapter-based Question Bank Section
                    ChapterQuestionBankSection(navigateToChapters: $navigateToChapters)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Past Exam Papers Section
                    PastExamPapersSection()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("题库")
            .navigationDestination(isPresented: $navigateToChapters) {
                ChapterSelectionView()
            }
        }
    }
}

// MARK: - Chapter Question Bank Section
struct ChapterQuestionBankSection: View {
    @Binding var navigateToChapters: Bool
    @StateObject private var userPreferences = UserPreferences.shared
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 20, weight: .semibold))
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
                
                Text("分章题库")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Three Features
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "list.bullet.rectangle",
                    title: "全章节覆盖",
                    description: "涵盖考试大纲所有章节",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "square.stack.3d.up.fill",
                    title: "每个章节多组题目",
                    description: "丰富题目库，全面练习",
                    color: .purple
                )
                
                FeatureRow(
                    icon: "slider.horizontal.3",
                    title: "三种练习模式",
                    description: "顺序练习/背题模式/模拟考试",
                    color: .orange
                )
            }
            
            // Start Practice Button
            Button(action: {
                // Check if course is selected
                if userPreferences.selectedCourseId != nil {
                    navigateToChapters = true
                } else {
                    print("Please select a course first")
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("开始练习")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.4, blue: 0.9),
                            Color(red: 0.5, green: 0.3, blue: 0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.05))
        )
    }
}

// MARK: - Past Exam Papers Section
struct PastExamPapersSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.9),
                                Color(red: 0.3, green: 0.5, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("历年真题")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Three Modules
            VStack(spacing: 12) {
                ExamModuleCard(
                    icon: "brain.head.profile",
                    title: "综合知识",
                    subtitle: "上午考试 · 75道选择题",
                    color: .blue,
                    availableCount: 12
                )
                
                ExamModuleCard(
                    icon: "doc.plaintext",
                    title: "案例题",
                    subtitle: "上午考试 · 案例分析",
                    color: .green,
                    availableCount: 10
                )
                
                ExamModuleCard(
                    icon: "pencil.and.outline",
                    title: "论文",
                    subtitle: "下午考试 · 论文写作",
                    color: .orange,
                    availableCount: 8
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Exam Module Card
struct ExamModuleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let availableCount: Int
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Navigate to exam papers list
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Available count and arrow
                VStack(spacing: 4) {
                    Text("\(availableCount)套")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    QuestionBankView()
}
