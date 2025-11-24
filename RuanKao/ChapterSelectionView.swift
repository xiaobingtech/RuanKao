//
//  ChapterSelectionView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/24.
//

import SwiftUI

struct ChapterSelectionView: View {
    @StateObject private var userPreferences = UserPreferences.shared
    @Environment(\.dismiss) var dismiss
    @State private var chapters: [ChapterInfo] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.5, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("选择章节")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(userPreferences.courseDisplayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 32)
                
                // Chapter List
                if chapters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("暂无章节数据")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(chapters) { chapter in
                            ChapterCard(chapter: chapter)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("分章题库")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadChapters()
        }
    }
    
    private func loadChapters() {
        guard let courseId = userPreferences.selectedCourseId else {
            print("No course selected")
            return
        }
        
        // Determine the path based on course_id
        let courseName = courseId == 3 ? "高项" : "中项"
        let bundlePath = "杨老师题库/\\(courseName)/分章题库"
        
        guard let bundle = Bundle.main.path(forResource: "Question", ofType: "bundle"),
              let questionBundle = Bundle(path: bundle) else {
            print("Cannot find Question.bundle")
            return
        }
        
        guard let resourcePath = questionBundle.resourcePath else {
            print("Cannot get resource path")
            return
        }
        
        let chapterPath = "\\(resourcePath)/\\(bundlePath)"
        
        do {
            let fileManager = FileManager.default
            let chapterFolders = try fileManager.contentsOfDirectory(atPath: chapterPath)
            
            var loadedChapters: [ChapterInfo] = []
            
            for folder in chapterFolders where !folder.hasPrefix(".") {
                let folderPath = "\\(chapterPath)/\\(folder)"
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: folderPath, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Count JSON files in this chapter
                    let files = try fileManager.contentsOfDirectory(atPath: folderPath)
                    let jsonFiles = files.filter { $0.hasSuffix(".json") }
                    
                    let chapterInfo = ChapterInfo(
                        name: folder,
                        questionGroupCount: jsonFiles.count,
                        path: folderPath
                    )
                    loadedChapters.append(chapterInfo)
                }
            }
            
            // Sort chapters
            self.chapters = loadedChapters.sorted { $0.name < $1.name }
            
            print("Loaded \\(chapters.count) chapters for course: \\(courseName)")
        } catch {
            print("Error loading chapters: \\(error)")
        }
    }
}

// MARK: - Chapter Info Model
struct ChapterInfo: Identifiable {
    let id = UUID()
    let name: String
    let questionGroupCount: Int
    let path: String
}

// MARK: - Chapter Card
struct ChapterCard: View {
    let chapter: ChapterInfo
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Navigate to question practice
            print("Selected chapter: \\(chapter.name)")
        }) {
            HStack(spacing: 16) {
                // Chapter Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.5, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "book.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Chapter Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(chapter.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\\(chapter.questionGroupCount)组题目")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    NavigationStack {
        ChapterSelectionView()
    }
}
