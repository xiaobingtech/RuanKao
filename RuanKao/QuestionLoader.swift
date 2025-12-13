//
//  QuestionLoader.swift
//  RuanKao
//
//  Created by GPT on 2025/12/13.
//

import Foundation

enum QuestionLoaderError: Error {
    case questionBundleNotFound
    case fileNotFound(String)
}

enum ChineseNumber {
    /// 1...20 -> 一...二十（超出范围则返回阿拉伯数字）
    static func from(_ number: Int) -> String {
        let chineseNumbers = [
            "一", "二", "三", "四", "五",
            "六", "七", "八", "九", "十",
            "十一", "十二", "十三", "十四", "十五",
            "十六", "十七", "十八", "十九", "二十"
        ]
        guard number > 0, number <= chineseNumbers.count else { return "\(number)" }
        return chineseNumbers[number - 1]
    }
}

actor QuestionLoader {
    static let shared = QuestionLoader()
    
    /// 简单内存缓存：避免 iOS17 上因 View 反复创建导致重复解码（CPU 飙升/内存抖动）
    private var cache: [String: [Question]] = [:]
    
    func loadChapterQuestions(courseId: Int, chapterName: String, groupNumber: Int) async throws -> [Question] {
        let courseName = courseId == 3 ? "高项" : "中项"
        let fileName = "第\(ChineseNumber.from(groupNumber))组.json"
        let relativePath = "杨老师题库/\(courseName)/分章题库/\(chapterName)/\(fileName)"
        let cacheKey = "chapter|\(courseId)|\(chapterName)|\(groupNumber)"
        return try await loadQuestions(relativePath: relativePath, cacheKey: cacheKey)
    }
    
    func loadExamQuestions(courseId: Int, category: ExamCategory, year: String, batch: String) async throws -> [Question] {
        let courseName = courseId == 3 ? "高项" : "中项"
        let fileName = "\(year)\(batch).json"
        let relativePath = "杨老师题库/\(courseName)/历年真题/\(category.rawValue)/\(year)/\(fileName)"
        let cacheKey = "exam|\(courseId)|\(category.rawValue)|\(year)|\(batch)"
        return try await loadQuestions(relativePath: relativePath, cacheKey: cacheKey)
    }
    
    private func loadQuestions(relativePath: String, cacheKey: String) async throws -> [Question] {
        if let cached = cache[cacheKey] {
            return cached
        }
        
        // 文件 IO + JSON 解码放到后台线程，避免卡主主线程（iOS17 更容易被放大）
        let questions: [Question] = try await Task.detached(priority: .userInitiated) {
            guard let bundleURL = Bundle.main.url(forResource: "Question", withExtension: "bundle"),
                  let questionBundle = Bundle(url: bundleURL) else {
                throw QuestionLoaderError.questionBundleNotFound
            }
            
            guard let fileURL = questionBundle.url(forResource: relativePath, withExtension: nil) else {
                throw QuestionLoaderError.fileNotFound(relativePath)
            }
            
            let data = try Data(contentsOf: fileURL)
            let response = try JSONDecoder().decode(QuestionResponse.self, from: data)
            return response.data.data
        }.value
        
        cache[cacheKey] = questions
        return questions
    }
}


