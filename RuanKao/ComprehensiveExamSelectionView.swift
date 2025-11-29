//
//  ComprehensiveExamSelectionView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI

// MARK: - Comprehensive Exam Selection View
struct ComprehensiveExamSelectionView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var yearGroups: [YearGroup] = []
    @State private var isLoading = true
    @State private var selectedYear: String?
    @State private var selectedBatch: String?
    @State private var selectedMode: PracticeMode?
    @State private var showModeSelection = false
    
    var isConfirmEnabled: Bool {
        selectedYear != nil && selectedBatch != nil && selectedMode != nil
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
        .navigationTitle("综合知识")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .overlay {
            if showModeSelection {
                modeSelectionPopup
            }
        }
        .onAppear {
            loadYearGroups()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.blue.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("选择年份、批次和练习模式")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("上午考试 · 75道选择题")
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
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedYear = year
                selectedBatch = batch
                // Reset mode when changing selection
                selectedMode = nil
                // Show mode selection popup
                showModeSelection = true
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? Color.blue : .secondary)
                
                Text(batch)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                          Color.blue.opacity(0.1) :
                            Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ?
                        Color.blue :
                            Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var practiceModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                
                Text("练习模式")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(PracticeMode.allCases) { mode in
                    ModeSelectionCard(
                        mode: mode,
                        isSelected: selectedMode == mode
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMode = mode
                        }
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
    
    private var confirmButton: some View {
        NavigationLink(
            destination: Group {
                if let year = selectedYear, 
                   let batch = selectedBatch,
                   let mode = selectedMode,
                   let courseId = userPreferences.selectedCourseId {
                    ComprehensiveQuestionPracticeView(
                        year: year,
                        batch: batch,
                        practiceMode: mode,
                        courseId: courseId
                    )
                }
            }
        ) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("开始练习")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: isConfirmEnabled ? [
                        Color(red: 0.3, green: 0.4, blue: 0.9),
                        Color(red: 0.5, green: 0.3, blue: 0.8)
                    ] : [Color.gray, Color.gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(
                color: isConfirmEnabled ? Color(red: 0.4, green: 0.35, blue: 0.85).opacity(0.3) : Color.clear,
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(!isConfirmEnabled)
    }
    
    // MARK: - Mode Selection Popup
    private var modeSelectionPopup: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showModeSelection = false
                    }
                }
            
            // Popup dialog
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                        
                        Text("选择练习模式")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showModeSelection = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let year = selectedYear, let batch = selectedBatch {
                        HStack {
                            Text("\(year)年 · \(batch)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(20)
                
                Divider()
                
                // Mode selection
                VStack(spacing: 12) {
                    ForEach(PracticeMode.allCases) { mode in
                        ModeSelectionCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMode = mode
                            }
                        }
                    }
                }
                .padding(20)
                
                Divider()
                
                // Confirm button
                VStack(spacing: 0) {
                    if selectedMode != nil {
                        NavigationLink(
                            destination: Group {
                                if let year = selectedYear,
                                   let batch = selectedBatch,
                                   let mode = selectedMode,
                                   let courseId = userPreferences.selectedCourseId {
                                    ComprehensiveQuestionPracticeView(
                                        year: year,
                                        batch: batch,
                                        practiceMode: mode,
                                        courseId: courseId
                                    )
                                }
                            }
                        ) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("开始练习")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
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
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(
                                color: Color(red: 0.4, green: 0.35, blue: 0.85).opacity(0.3),
                                radius: 8, x: 0, y: 4
                            )
                        }
                        .padding(20)
                    }
                }
            }
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .zIndex(1)
    }
    
    private func loadYearGroups() {
        guard let courseId = userPreferences.selectedCourseId else {
            print("No course selected")
            isLoading = false
            return
        }
        
        // Load and sort by year in descending order (newest first)
        yearGroups = ExamPaperHelper.getYearGroups(courseId: courseId, category: .comprehensive)
            .sorted { Int($0.year) ?? 0 > Int($1.year) ?? 0 }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        ComprehensiveExamSelectionView()
    }
}
