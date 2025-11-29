//
//  WrongQuestionListView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/26.
//

import SwiftUI
import SwiftData

struct WrongQuestionListView: View {
    @ObservedObject private var userPreferences = UserPreferences.shared
    
    var body: some View {
        if let courseId = userPreferences.selectedCourseId {
            WrongQuestionListContentView(courseId: courseId)
        } else {
            WrongQuestionListContentView(courseId: 4)
//            ContentUnavailableView("请先选择课程", systemImage: "book.closed")
        }
    }
}

struct WrongQuestionListContentView: View {
    let courseId: Int
    @Environment(\.modelContext) private var modelContext
    @Query private var wrongQuestions: [WrongQuestion]
    
    init(courseId: Int) {
        self.courseId = courseId
        let predicate = #Predicate<WrongQuestion> {
            $0.courseId == courseId
        }
        self._wrongQuestions = Query(filter: predicate, sort: \.lastWrongDate, order: .reverse)
    }
    
    var body: some View {
        ZStack {
            if wrongQuestions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(wrongQuestions.enumerated()), id: \.element.questionId) { index, wrongQuestion in
                            NavigationLink(destination: WrongQuestionPracticeView(
                                wrongQuestions: wrongQuestions,
                                startIndex: index
                            )) {
                                WrongQuestionListCard(wrongQuestion: wrongQuestion, index: index + 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("错题本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
            // ... (rest of the view remains the same)
            .font(.system(size: 60))
            .foregroundColor(.green)
            
            Text("暂无错题")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("完成模拟考试后，错题会自动保存到这里")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Wrong Question List Card
struct WrongQuestionListCard: View {
    let wrongQuestion: WrongQuestion
    let index: Int
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("第 \(index) 题")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Wrong count badge
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                        Text("\(wrongQuestion.wrongCount)次")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Delete button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Question Stem
            Text(wrongQuestion.tigan)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Answers
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("你的答案：")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(wrongQuestion.userAnswer)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.red)
                }
                
                HStack(spacing: 4) {
                    Text("正确答案：")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(wrongQuestion.correctAnswer)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            // Date
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                Text(wrongQuestion.lastWrongDate, style: .date)
                    .font(.system(size: 12, weight: .regular))
                
                Spacer()
            }
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteWrongQuestion()
            }
        } message: {
            Text("确定要从错题本中删除这道题吗？")
        }
    }
    
    private func deleteWrongQuestion() {
        modelContext.delete(wrongQuestion)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        WrongQuestionListView()
            .modelContainer(for: WrongQuestion.self, inMemory: true)
    }
}
