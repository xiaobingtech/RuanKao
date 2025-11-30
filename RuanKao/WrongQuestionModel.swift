//
//  WrongQuestionModel.swift
//  RuanKao
//
//  Created by fandong on 2025/11/26.
//

import Foundation
import SwiftData

@Model
final class WrongQuestion {
    // CloudKit doesn't support unique constraints, so we remove @Attribute(.unique)
    // We'll handle deduplication in the app code instead
    var questionId: String = ""
    var courseId: Int = 0
    var seq: Int = 0
    var testId: String = ""
    var type: Int = 0
    var area: Int = 0
    var tigan: String = ""
    var tiganPic: String = ""
    var optionA: String = ""
    var optionB: String = ""
    var optionC: String = ""
    var optionD: String = ""
    var correctAnswer: String = ""
    var userAnswer: String = ""
    var explanation: String = ""
    var explanationPic: String = ""
    var wrongCount: Int = 1
    var lastWrongDate: Date = Date()
    
    init(
        questionId: String,
        courseId: Int,
        seq: Int,
        testId: String,
        type: Int,
        area: Int,
        tigan: String,
        tiganPic: String,
        optionA: String,
        optionB: String,
        optionC: String,
        optionD: String,
        correctAnswer: String,
        userAnswer: String,
        explanation: String,
        explanationPic: String,
        wrongCount: Int = 1,
        lastWrongDate: Date = Date()
    ) {
        self.questionId = questionId
        self.courseId = courseId
        self.seq = seq
        self.testId = testId
        self.type = type
        self.area = area
        self.tigan = tigan
        self.tiganPic = tiganPic
        self.optionA = optionA
        self.optionB = optionB
        self.optionC = optionC
        self.optionD = optionD
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.explanation = explanation
        self.explanationPic = explanationPic
        self.wrongCount = wrongCount
        self.lastWrongDate = lastWrongDate
    }
    
    // Convenience initializer from Question model
    convenience init(from question: Question, userAnswer: String) {
        self.init(
            questionId: question.id,
            courseId: question.courseId,
            seq: question.seq,
            testId: question.testId,
            type: question.type,
            area: question.area,
            tigan: question.tigan,
            tiganPic: question.tiganPic,
            optionA: question.A,
            optionB: question.B,
            optionC: question.C,
            optionD: question.D,
            correctAnswer: question.answer,
            userAnswer: userAnswer,
            explanation: question.explanation,
            explanationPic: question.explanationPic
        )
    }
    
    // Helper to get image URL similar to Question model
    var tiganPicUrl: URL? {
        guard !tiganPic.isEmpty else { return nil }
        let baseUrl = "http://static.ruankao.app.xiaobingkj.com/course_\(courseId)"
        return URL(string: "\(baseUrl)/\(tiganPic)")
    }
    
    var explanationPicUrl: URL? {
        guard !explanationPic.isEmpty else { return nil }
        let baseUrl = "http://static.ruankao.app.xiaobingkj.com/course_\(courseId)"
        return URL(string: "\(baseUrl)/\(explanationPic)")
    }
}
