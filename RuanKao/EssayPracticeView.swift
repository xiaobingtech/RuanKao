//
//  EssayPracticeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI

// MARK: - Essay Practice View (for Case Study and Essay questions)
struct EssayPracticeView: View {
    let category: ExamCategory
    let year: String
    let batch: String
    
    @Environment(\.dismiss) var dismiss
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var isLoading = true
    @State private var selectedImage: ImageItem?
    
    var currentQuestion: Question? {
        guard !questions.isEmpty, currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isFirstQuestion: Bool {
        currentQuestionIndex == 0
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("加载中...")
            } else {
                essayContentView
            }
        }
        .navigationTitle("\(year)\(batch)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadQuestions()
        }
        .fullScreenCover(item: $selectedImage) { item in
            FullScreenImageView(imageUrl: item.url, isPresented: Binding(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            ))
        }
    }
    
    private var essayContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let question = currentQuestion {
                    // Progress Indicator
                    HStack {
                        Text("\(currentQuestionIndex + 1)/\(questions.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                        
                        Spacer()
                        
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Question Stem (题干)
                    VStack(alignment: .leading, spacing: 12) {
                        if let url = question.tiganPicUrl {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .frame(maxWidth: .infinity)
                                case .failure:
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle")
                                        Text("图片加载失败")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(maxHeight: 300)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .onTapGesture {
                                selectedImage = ImageItem(url: url)
                            }
                        }
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                            Text("题干")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text(question.tigan)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    
                    
                    // Explanation (解析)
                    if !question.explanation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                Text("答案解析")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            if let url = question.explanationPicUrl {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(8)
                                            .frame(maxWidth: .infinity)
                                    case .failure:
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle")
                                            Text("图片加载失败")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(maxHeight: 300)
                                .padding(.top, 8)
                                .onTapGesture {
                                    selectedImage = ImageItem(url: url)
                                }
                            }
                            
                            Text(question.explanation)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        Button(action: previousQuestion) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("上一题")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isFirstQuestion ? Color.gray.opacity(0.3) : Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundColor(isFirstQuestion ? .gray : Color(red: 0.4, green: 0.35, blue: 0.85))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .disabled(isFirstQuestion)
                        
                        if isLastQuestion {
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("完成")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
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
                            }
                        } else {
                            Button(action: nextQuestion) {
                                HStack {
                                    Text("下一题")
                                    Image(systemName: "chevron.right")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
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
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func loadQuestions() {
        guard let courseId = UserPreferences.shared.selectedCourseId else {
            print("No course selected")
            isLoading = false
            return
        }
        
        questions = ExamPaperHelper.loadQuestions(
            courseId: courseId,
            category: category,
            year: year,
            batch: batch
        )
        
        isLoading = false
        print("Loaded \(questions.count) \(category.rawValue) questions")
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation {
                currentQuestionIndex -= 1
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        }
    }
}

#Preview {
    NavigationStack {
        EssayPracticeView(
            category: .caseStudy,
            year: "2016",
            batch: "第一批"
        )
    }
}
