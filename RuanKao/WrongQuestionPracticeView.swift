//
//  WrongQuestionPracticeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/26.
//

import SwiftUI
import SwiftData

struct WrongQuestionPracticeView: View {
    let wrongQuestions: [WrongQuestion]
    let startIndex: Int
    
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex: Int
    @State private var selectedImage: ImageItem?
    
    init(wrongQuestions: [WrongQuestion], startIndex: Int) {
        self.wrongQuestions = wrongQuestions
        self.startIndex = startIndex
        _currentQuestionIndex = State(initialValue: startIndex)
    }
    
    var currentQuestion: WrongQuestion? {
        guard !wrongQuestions.isEmpty, currentQuestionIndex < wrongQuestions.count else { return nil }
        return wrongQuestions[currentQuestionIndex]
    }
    
    var isFirstQuestion: Bool {
        currentQuestionIndex == 0
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == wrongQuestions.count - 1
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let question = currentQuestion {
                    // Progress Indicator
                    HStack {
                        Text("\(currentQuestionIndex + 1)/\(wrongQuestions.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                        
                        Spacer()
                        
                        // Wrong count badge
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                            Text("错误\(question.wrongCount)次")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Question Stem
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
                            .padding(.top, 8)
                            .onTapGesture {
                                selectedImage = ImageItem(url: url)
                            }
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(question.seq).")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
                            
                            Text(question.tigan)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Options
                    VStack(spacing: 12) {
                        WrongQuestionOptionView(
                            option: "A",
                            text: question.optionA,
                            isUserAnswer: question.userAnswer == "A",
                            isCorrect: question.correctAnswer == "A"
                        )
                        
                        WrongQuestionOptionView(
                            option: "B",
                            text: question.optionB,
                            isUserAnswer: question.userAnswer == "B",
                            isCorrect: question.correctAnswer == "B"
                        )
                        
                        WrongQuestionOptionView(
                            option: "C",
                            text: question.optionC,
                            isUserAnswer: question.userAnswer == "C",
                            isCorrect: question.correctAnswer == "C"
                        )
                        
                        WrongQuestionOptionView(
                            option: "D",
                            text: question.optionD,
                            isUserAnswer: question.userAnswer == "D",
                            isCorrect: question.correctAnswer == "D"
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
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("完成练习")
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
                    
                    // Explanation
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
                    
                    Spacer()
                        .frame(height: 24)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("错题练习")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(item: $selectedImage) { item in
            FullScreenImageView(imageUrl: item.url, isPresented: Binding(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            ))
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation {
                currentQuestionIndex -= 1
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < wrongQuestions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        }
    }
}

// MARK: - Wrong Question Option View
struct WrongQuestionOptionView: View {
    let option: String
    let text: String
    let isUserAnswer: Bool
    let isCorrect: Bool
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.1)
        } else if isUserAnswer {
            return Color.red.opacity(0.1)
        } else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isUserAnswer {
            return Color.red
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    var optionCircleColor: Color {
        if isCorrect {
            return Color.green
        } else if isUserAnswer {
            return Color.red
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Option Circle
            ZStack {
                Circle()
                    .fill(optionCircleColor)
                    .frame(width: 28, height: 28)
                
                Text(option)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Option Text
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Status Icon
            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            } else if isUserAnswer {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        WrongQuestionPracticeView(wrongQuestions: [], startIndex: 0)
            .modelContainer(for: WrongQuestion.self, inMemory: true)
    }
}
