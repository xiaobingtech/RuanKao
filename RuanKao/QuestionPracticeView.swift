//
//  QuestionPracticeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI

// MARK: - Question Model
struct Question: Codable, Identifiable {
    let id: String // Use _id from JSON as the unique identifier
    let courseId: Int
    let questionId: Int
    let seq: Int
    let testId: String
    let type: Int
    let area: Int
    let tigan: String
    let A: String
    let B: String
    let C: String
    let D: String
    let answer: String
    let explanation: String
    let tiganPic: String
    let explanationPic: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case courseId = "course_id"
        case questionId = "id"
        case seq
        case testId = "test_id"
        case type
        case area
        case tigan
        case A, B, C, D
        case answer
        case explanation
        case tiganPic = "tigan_pic"
        case explanationPic = "explanation_pic"
    }
    
    // Custom decoder to handle both String and numeric values for A, B, C, D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        courseId = try container.decode(Int.self, forKey: .courseId)
        questionId = try container.decode(Int.self, forKey: .questionId)
        seq = try container.decode(Int.self, forKey: .seq)
        testId = try container.decode(String.self, forKey: .testId)
        type = try container.decode(Int.self, forKey: .type)
        area = try container.decode(Int.self, forKey: .area)
        tigan = try container.decode(String.self, forKey: .tigan)
        
        // Handle A, B, C, D - can be either String or Number
        A = try Self.decodeStringOrNumber(from: container, forKey: .A)
        B = try Self.decodeStringOrNumber(from: container, forKey: .B)
        C = try Self.decodeStringOrNumber(from: container, forKey: .C)
        D = try Self.decodeStringOrNumber(from: container, forKey: .D)
        
        answer = try container.decode(String.self, forKey: .answer)
        explanation = try container.decode(String.self, forKey: .explanation)
        tiganPic = try container.decode(String.self, forKey: .tiganPic)
        explanationPic = try container.decode(String.self, forKey: .explanationPic)
    }
    
    // Helper method to decode either String or Number
    private static func decodeStringOrNumber(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> String {
        // Try to decode as String first
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue
        }
        // If that fails, try to decode as Int
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return String(intValue)
        }
        // If that fails, try to decode as Double
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return String(doubleValue)
        }
        // If all fail, return empty string
        return ""
    }
    
    var tiganPicUrl: URL? {
        guard !tiganPic.isEmpty else { return nil }
        let baseUrl = "https://mp-1af92f1c-94c6-441d-86c3-3a0c66fb0618.cdn.bspapp.com/tiku"
        return URL(string: "\(baseUrl)/\(courseId)/\(tiganPic)")
    }
}

struct QuestionResponse: Codable {
    let success: Bool
    let data: QuestionData
}

struct QuestionData: Codable {
    let errCode: Int
    let errMsg: String
    let data: [Question]
}

// MARK: - Question Practice View
struct QuestionPracticeView: View {
    let chapter: ChapterInfo
    let groupNumber: Int
    let practiceMode: PracticeMode
    
    @Environment(\.dismiss) var dismiss
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var userAnswers: [String: String] = [:] // questionId: selectedAnswer
    @State private var showExamResult = false
    @State private var isLoading = true
    
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
                    onDismiss: {
                        dismiss()
                    }
                )
            } else {
                questionContentView
            }
        }
        .navigationTitle("\(chapter.name) - 第\(groupNumber)组")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showExamResult)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadQuestions()
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
                        
                        if practiceMode == .simulation {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(correctCount)")
                                
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("\(userAnswers.count - correctCount)")
                            }
                            .font(.system(size: 14, weight: .medium))
                        }
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
        guard let courseId = UserPreferences.shared.selectedCourseId else {
            print("No course selected")
            isLoading = false
            return
        }
        
        let courseName = courseId == 3 ? "高项" : "中项"
        let fileName = "第\(convertNumberToChinese(groupNumber))组"
        let filePath = "/杨老师题库/\(courseName)/分章题库/\(chapter.name)/\(fileName).json"
        
        guard let bundle = Bundle.main.path(forResource: "Question", ofType: "bundle"),
              let questionBundle = Bundle(path: bundle) else {
            print("Cannot find Question.bundle")
            isLoading = false
            return
        }
        
        guard let resourcePath = questionBundle.resourcePath else {
            print("Cannot get resource path")
            isLoading = false
            return
        }
        
        let fullPath = "\(resourcePath)\(filePath)"
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
            let response = try JSONDecoder().decode(QuestionResponse.self, from: data)
            self.questions = response.data.data
            isLoading = false
            print("Loaded \(questions.count) questions")
        } catch {
            print("Error loading questions: \(error)")
            isLoading = false
        }
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
    
    private func convertNumberToChinese(_ number: Int) -> String {
        let chineseNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
                              "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十"]
        guard number > 0, number <= chineseNumbers.count else { return "\(number)" }
        return chineseNumbers[number - 1]
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let option: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let showAnswer: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var backgroundColor: Color {
        if showAnswer && isCorrect {
            return Color.green.opacity(0.1)
        } else if isSelected {
            return Color(red: 0.3, green: 0.4, blue: 0.9).opacity(0.1)
        } else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
    
    var borderColor: Color {
        if showAnswer && isCorrect {
            return Color.green
        } else if isSelected {
            return Color(red: 0.3, green: 0.4, blue: 0.9)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    var optionCircleColor: Color {
        if showAnswer && isCorrect {
            return Color.green
        } else if isSelected {
            return Color(red: 0.3, green: 0.4, blue: 0.9)
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
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
                
                // Checkmark for correct answer in memorization mode
                if showAnswer && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: showAnswer && isCorrect ? 2 : (isSelected ? 2 : 1))
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showAnswer)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Exam Result View
struct ExamResultView: View {
    let totalQuestions: Int
    let correctCount: Int
    let wrongQuestions: [(Question, String)]
    let onDismiss: () -> Void
    
    var score: Int {
        Int((Double(correctCount) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Score Display
                VStack(spacing: 16) {
                    Image(systemName: score >= 60 ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(score >= 60 ? .green : .red)
                    
                    Text("\(score)分")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(score >= 60 ? "考试通过！" : "继续加油！")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 32) {
                        VStack(spacing: 8) {
                            Text("\(totalQuestions)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            Text("总题数")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(correctCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                            Text("正确")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(totalQuestions - correctCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)
                            Text("错误")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 32)
                
                // Buttons
                VStack(spacing: 16) {
                    // Wrong Questions Button (if any)
                    if !wrongQuestions.isEmpty {
                        NavigationLink(destination: WrongQuestionsView(wrongQuestions: wrongQuestions)) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("错题记录 (\(wrongQuestions.count))")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Back to Home Button
                    Button(action: onDismiss) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("回到首页")
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
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Wrong Questions View
struct WrongQuestionsView: View {
    let wrongQuestions: [(Question, String)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(wrongQuestions.enumerated()), id: \.element.0.id) { index, item in
                    let (question, userAnswer) = item
                    WrongQuestionCard(question: question, userAnswer: userAnswer, index: index + 1)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("错题记录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Wrong Question Card
struct WrongQuestionCard: View {
    let question: Question
    let userAnswer: String
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question Number
            Text("第 \(index) 题")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
            
            // Question Stem
            Text(question.tigan)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
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
                .frame(maxHeight: 200)
            }
            
            // User's Answer
            HStack {
                Text("你的答案：")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(userAnswer)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            }
            
            // Correct Answer
            HStack {
                Text("正确答案：")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(question.answer)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            }
            
            // Explanation
            if !question.explanation.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("解析")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Text(question.explanation)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        QuestionPracticeView(
            chapter: ChapterInfo(
                name: "第一章 信息化发展",
                questionGroupCount: 3,
                path: "/path/to/chapter"
            ),
            groupNumber: 1,
            practiceMode: .memorization
        )
    }
}
