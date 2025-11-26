//
//  StudyStatisticsModel.swift
//  RuanKao
//
//  Created by fandong on 2025/11/26.
//

import Foundation
import SwiftData

@Model
final class StudyStatistics {
    var courseId: Int = 0
    var practiceQuestions: Int = 0
    var correctAnswers: Int = 0
    var studyDuration: TimeInterval = 0
    var completedExams: Int = 0
    var lastUpdated: Date = Date()
    
    init(
        courseId: Int,
        practiceQuestions: Int = 0,
        correctAnswers: Int = 0,
        studyDuration: TimeInterval = 0,
        completedExams: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.courseId = courseId
        self.practiceQuestions = practiceQuestions
        self.correctAnswers = correctAnswers
        self.studyDuration = studyDuration
        self.completedExams = completedExams
        self.lastUpdated = lastUpdated
    }
    
    // Helper computed property for average accuracy
    var averageAccuracy: Double {
        guard practiceQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(practiceQuestions) * 100.0
    }
    
    // Helper method to update statistics after practice
    func recordPractice(isCorrect: Bool, duration: TimeInterval) {
        practiceQuestions += 1
        if isCorrect {
            correctAnswers += 1
        }
        studyDuration += duration
        lastUpdated = Date()
    }
    
    // Helper method to update statistics after exam
    func recordExam(totalQuestions: Int, correctCount: Int, duration: TimeInterval) {
        completedExams += 1
        practiceQuestions += totalQuestions
        correctAnswers += correctCount
        studyDuration += duration
        lastUpdated = Date()
    }
}
