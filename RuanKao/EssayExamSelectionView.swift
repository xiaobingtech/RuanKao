//
//  EssayExamSelectionView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI

// MARK: - Essay Exam Selection View (for Case Study and Essay)
struct EssayExamSelectionView: View {
    let category: ExamCategory
    
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var yearGroups: [YearGroup] = []
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                if isLoading {
                    ProgressView("加载中...")
                        .padding()
                } else if yearGroups.isEmpty {
                    emptyStateView
                } else {
                    // Year Sections
                    ForEach(yearGroups) { yearGroup in
                        yearSectionView(yearGroup: yearGroup)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                    .frame(height: 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadYearGroups()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: category == .caseStudy ? "doc.plaintext" : "pencil.and.outline")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            category == .caseStudy ? Color.green : Color.orange,
                            category == .caseStudy ? Color.green.opacity(0.7) : Color.orange.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("选择年份和批次")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("直接查看题干和解析")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 24)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无历年真题")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("请稍后再试")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
    
    private func yearSectionView(yearGroup: YearGroup) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Year Header
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                
                Text("\(yearGroup.year)年")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Batch Cards
            VStack(spacing: 12) {
                ForEach(yearGroup.batches, id: \.self) { batch in
                    NavigationLink(destination: EssayPracticeView(
                        category: category,
                        year: yearGroup.year,
                        batch: batch
                    )) {
                        BatchCard(batch: batch, color: category == .caseStudy ? .green : .orange)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func loadYearGroups() {
        guard let courseId = userPreferences.selectedCourseId else {
            print("No course selected")
            isLoading = false
            return
        }
        
        yearGroups = ExamPaperHelper.getYearGroups(courseId: courseId, category: category)
        isLoading = false
    }
}

// MARK: - Batch Card
struct BatchCard: View {
    let batch: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
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
                    .frame(width: 50, height: 50)
                
                Image(systemName: "doc.text")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Batch Name
            VStack(alignment: .leading, spacing: 4) {
                Text(batch)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("点击查看题目")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
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
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        EssayExamSelectionView(category: .caseStudy)
    }
}
