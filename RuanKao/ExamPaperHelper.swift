//
//  ExamPaperHelper.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import Foundation

// MARK: - Exam Paper Models
struct YearGroup: Identifiable {
    let id = UUID()
    let year: String
    let batches: [String] // e.g., ["第一批", "第二批"]
}

enum ExamCategory: String {
    case comprehensive = "综合知识"
    case caseStudy = "案例题"
    case essay = "论文"
}

// MARK: - Exam Paper Helper
class ExamPaperHelper {
    
    /// Get all available years and their batches for a specific exam category
    static func getYearGroups(courseId: Int, category: ExamCategory) -> [YearGroup] {
        let courseName = courseId == 3 ? "高项" : "中项"
        
        // Use proper Bundle API to get Question.bundle
        guard let questionBundlePath = Bundle.main.path(forResource: "Question", ofType: "bundle"),
              let questionBundle = Bundle(path: questionBundlePath) else {
            print("Error: Question.bundle not found")
            return []
        }
        
        // Construct path within the bundle
        let relativePath = "杨老师题库/\(courseName)/历年真题/\(category.rawValue)"
        guard let categoryPath = questionBundle.path(forResource: relativePath, ofType: nil) else {
            print("Error: Category path not found: \(relativePath)")
            return []
        }
        
        var yearGroups: [YearGroup] = []
        let fileManager = FileManager.default
        let categoryURL = URL(fileURLWithPath: categoryPath)
        
        do {
            // Get all year directories
            let yearDirs = try fileManager.contentsOfDirectory(at: categoryURL, includingPropertiesForKeys: nil)
                .filter { $0.hasDirectoryPath }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            for yearDir in yearDirs {
                let year = yearDir.lastPathComponent
                
                // Get all JSON files (batches) in this year directory
                let jsonFiles = try fileManager.contentsOfDirectory(at: yearDir, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "json" }
                    .sorted { $0.lastPathComponent < $1.lastPathComponent }
                
                // Extract batch names from file names (e.g., "2016第一批.json" -> "第一批")
                let batches = jsonFiles.compactMap { file -> String? in
                    let fileName = file.deletingPathExtension().lastPathComponent
                    // Remove year prefix to get batch name
                    if let range = fileName.range(of: year) {
                        return String(fileName[range.upperBound...])
                    }
                    return nil
                }
                
                if !batches.isEmpty {
                    yearGroups.append(YearGroup(year: year, batches: batches))
                }
            }
        } catch {
            print("Error reading year directories: \(error)")
        }
        
        return yearGroups
    }
    
    /// Construct file path for loading exam paper data
    static func constructFilePath(courseId: Int, category: ExamCategory, year: String, batch: String) -> String {
        let courseName = courseId == 3 ? "高项" : "中项"
        let fileName = "\(year)\(batch).json"
        return "/杨老师题库/\(courseName)/历年真题/\(category.rawValue)/\(year)/\(fileName)"
    }
    
    /// Load questions from exam paper file
    static func loadQuestions(courseId: Int, category: ExamCategory, year: String, batch: String) -> [Question] {
        guard let bundle = Bundle.main.path(forResource: "Question", ofType: "bundle"),
              let questionBundle = Bundle(path: bundle),
              let resourcePath = questionBundle.resourcePath else {
            print("Cannot find Question.bundle")
            return []
        }
        
        let filePath = constructFilePath(courseId: courseId, category: category, year: year, batch: batch)
        let fullPath = "\(resourcePath)\(filePath)"
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
            let response = try JSONDecoder().decode(QuestionResponse.self, from: data)
            return response.data.data
        } catch {
            print("Error loading questions from \(fullPath): \(error)")
            return []
        }
    }
}
