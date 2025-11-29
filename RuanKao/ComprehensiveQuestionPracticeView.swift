//
//  ComprehensiveQuestionPracticeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI
import SwiftData

// MARK: - Comprehensive Question Practice View
struct ComprehensiveQuestionPracticeView: View {
    let year: String
    let batch: String
    let practiceMode: PracticeMode
    let courseId: Int
    
    @Environment(\.dismiss) var dismiss
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var userAnswers: [String: String] = [:] // questionId: selectedAnswer
    @State private var showExamResult = false
    @State private var isLoading = true
    @State private var startTime: Date = Date()
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
    
    var correctCount: Int {
        userAnswers.filter { questionId, answer in
            questions.first(where: { $0.id == questionId })?.answer == answer
        }.count
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("加载中...")
            } else if showExamResult {
                ExamResultView(
                    totalQuestions: questions.count,
                    correctCount: correctCount,
                    wrongQuestions: getWrongQuestions(),
                    duration: Date().timeIntervalSince(startTime),
                    onDismiss: {
                        dismiss()
                    }
                )
            } else {
                questionContentView
            }
        }
        .navigationTitle("\(year)\(batch)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showExamResult)
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
    
    private var questionContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let question = currentQuestion {
                    // Progress Indicator
                    HStack {
                        Text("\(currentQuestionIndex + 1)/\(questions.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                        
                        Spacer()
                        
//                        if practiceMode == .simulation {
//                            HStack(spacing: 4) {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundColor(.green)
//                                Text("\(correctCount)")
//                                
//                                Image(systemName: "xmark.circle.fill")
//                                    .foregroundColor(.red)
//                                Text("\(userAnswers.count - correctCount)")
//                            }
//                            .font(.system(size: 14, weight: .medium))
//                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Question Stem
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(question.seq).")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                            
                            Text(question.tigan)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
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
                            .padding(.top, 8)
                            .onTapGesture {
                                selectedImage = ImageItem(url: url)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Options
                    VStack(spacing: 12) {
                        OptionButton(
                            option: "A",
                            text: question.A,
                            isSelected: userAnswers[question.id] == "A",
                            isCorrect: question.answer == "A",
                            showAnswer: practiceMode == .memorization,
                            onTap: {
                                selectAnswer(questionId: question.id, answer: "A")
                            }
                        )
                        
                        OptionButton(
                            option: "B",
                            text: question.B,
                            isSelected: userAnswers[question.id] == "B",
                            isCorrect: question.answer == "B",
                            showAnswer: practiceMode == .memorization,
                            onTap: {
                                selectAnswer(questionId: question.id, answer: "B")
                            }
                        )
                        
                        OptionButton(
                            option: "C",
                            text: question.C,
                            isSelected: userAnswers[question.id] == "C",
                            isCorrect: question.answer == "C",
                            showAnswer: practiceMode == .memorization,
                            onTap: {
                                selectAnswer(questionId: question.id, answer: "C")
                            }
                        )
                        
                        OptionButton(
                            option: "D",
                            text: question.D,
                            isSelected: userAnswers[question.id] == "D",
                            isCorrect: question.answer == "D",
                            showAnswer: practiceMode == .memorization,
                            onTap: {
                                selectAnswer(questionId: question.id, answer: "D")
                            }
                        )
                    }
                    .padding(.horizontal)
                    
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
                            Button(action: finishPractice) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(practiceMode == .simulation ? "完成考试" : "完成练习")
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
                    
                    // Explanation (for Memorization Mode)
                    if practiceMode == .memorization && !question.explanation.isEmpty {
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
                    
                    Spacer()
                        .frame(height: 24)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func loadQuestions() {
        questions = ExamPaperHelper.loadQuestions(
            courseId: courseId,
            category: .comprehensive,
            year: year,
            batch: batch
        )
        
        startTime = Date() // Reset start time when questions are loaded
        isLoading = false
        print("Loaded \(questions.count) comprehensive questions")
    }
    
    private func selectAnswer(questionId: String, answer: String) {
        userAnswers[questionId] = answer
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
    
    private func finishPractice() {
        if practiceMode == .simulation {
            showExamResult = true
        } else {
            dismiss()
        }
    }
    
    private func getWrongQuestions() -> [(Question, String)] {
        var wrongQuestions: [(Question, String)] = []
        for (questionId, userAnswer) in userAnswers {
            if let question = questions.first(where: { $0.id == questionId }),
               question.answer != userAnswer {
                wrongQuestions.append((question, userAnswer))
            }
        }
        return wrongQuestions
    }
}

#Preview {
    NavigationStack {
        ComprehensiveQuestionPracticeView(
            year: "2016",
            batch: "第一批",
            practiceMode: .memorization,
            courseId: 3
        )
    }
}
