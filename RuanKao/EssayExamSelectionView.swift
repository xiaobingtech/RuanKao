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
    @State private var selectedYear: String?
    @State private var selectedBatch: String?
    
    var isConfirmEnabled: Bool {
        selectedYear != nil && selectedBatch != nil
    }
    
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
                    contentView
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
    
    private var contentView: some View {
        VStack(spacing: 24) {
            // Year and Batch Selection Sections
            ForEach(yearGroups) { yearGroup in
                yearSectionView(yearGroup: yearGroup)
                    .padding(.horizontal)
            }
        }
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
            
            // Batch Selection (Grid layout, max 4 per row)
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(yearGroup.batches, id: \.self) { batch in
                    batchSelectionCard(year: yearGroup.year, batch: batch)
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
    
    private func batchSelectionCard(year: String, batch: String) -> some View {
        let isSelected = selectedYear == year && selectedBatch == batch
        let cardColor = category == .caseStudy ? Color.green : Color.orange
        
        return NavigationLink(destination: EssayPracticeView(
            category: category,
            year: year,
            batch: batch
        )) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? cardColor : .secondary)
                
                Text(batch)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                          cardColor.opacity(0.1) :
                            Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func loadYearGroups() {
        guard let courseId = userPreferences.selectedCourseId else {
            print("No course selected")
            isLoading = false
            return
        }
        
        // Load and sort by year in descending order (newest first)
        yearGroups = ExamPaperHelper.getYearGroups(courseId: courseId, category: category)
            .sorted { Int($0.year) ?? 0 > Int($1.year) ?? 0 }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        EssayExamSelectionView(category: .caseStudy)
    }
}
