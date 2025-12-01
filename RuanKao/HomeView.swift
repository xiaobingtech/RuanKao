//
//  HomeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject private var userPreferences = UserPreferences.shared
    
    var body: some View {
        NavigationStack {
            if let courseId = userPreferences.selectedCourseId {
                HomeContentView(courseId: courseId)
            } else {
                // Fallback or empty state if no course selected
//                ContentUnavailableView("请先选择课程", systemImage: "book.closed")
                HomeContentView(courseId: 4)
            }
        }
    }
}

struct HomeContentView: View {
    let courseId: Int
    
    // Countdown timer state
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    // SwiftData queries with dynamic filtering
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var allStatistics: [StudyStatistics]
    
    // Model context for creating/updating data
    @Environment(\.modelContext) private var modelContext
    
    // Safe async initialization of statistics
    @State private var statistics: StudyStatistics?
    
    init(courseId: Int) {
        self.courseId = courseId
        
        // Initialize queries with filter for specific course
        let wrongQuestionPredicate = #Predicate<WrongQuestion> {
            $0.courseId == courseId
        }
        self._wrongQuestions = Query(filter: wrongQuestionPredicate)
        
        let statsPredicate = #Predicate<StudyStatistics> {
            $0.courseId == courseId
        }
        self._allStatistics = Query(filter: statsPredicate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Countdown Section
                CountdownCard(timeRemaining: timeRemaining, courseId: courseId)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Study Statistics Section - use safe defaults if statistics not loaded
                StudyStatisticsCard(
                    practiceQuestions: statistics?.practiceQuestions ?? 0,
                    averageAccuracy: statistics?.averageAccuracy ?? 0.0,
                    studyDuration: statistics?.studyDuration ?? 0,
                    completedExams: statistics?.completedExams ?? 0,
                    errorCount: wrongQuestions.count
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("首页")
        .task {
            // Safely initialize statistics asynchronously after model context is ready
            await initializeStatistics()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Safe async initialization of statistics
    private func initializeStatistics() async {
        // Add small delay to ensure CloudKit/SwiftData is fully initialized
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Find statistics for current course
        if let existing = allStatistics.first {
            statistics = existing
        } else {
            // Create default statistics for this course if none exist
            let newStats = StudyStatistics(courseId: courseId)
            modelContext.insert(newStats)
            try? modelContext.save()
            statistics = newStats
        }
    }
    
    private func startTimer() {
        // Calculate initial time remaining
        updateTimeRemaining()
        
        // Start timer to update every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeRemaining() {
        // 中项: courseId = 4, 目标日期 2026年11月9日
        // 高项: courseId = 3, 目标日期 2026年5月24日
        let (year, month, day) = courseId == 4 ? (2026, 11, 9) : (2026, 5, 24)
        let targetDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 0, minute: 0))!
        let now = Date()
        timeRemaining = targetDate.timeIntervalSince(now)
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    let timeRemaining: TimeInterval
    let courseId: Int
    
    private var days: Int {
        Int(timeRemaining / 86400)
    }
    
    private var hours: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600)
    }
    
    private var minutes: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    private var seconds: Int {
        Int(timeRemaining.truncatingRemainder(dividingBy: 60))
    }
    
    private var targetDateText: String {
        // 中项: courseId = 4, 目标日期 2026年11月9日
        // 高项: courseId = 3, 目标日期 2026年5月24日
        return courseId == 4 ? "目标日期：2026年11月9日" : "目标日期：2026年5月24日"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                
                Text("考试倒计时")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Target Date
            Text(targetDateText)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // Countdown Display
            HStack(spacing: 8) {
                TimeUnitView(value: days, unit: "天", color: Color(red: 0.4, green: 0.7, blue: 1.0))
                TimeUnitView(value: hours, unit: "时", color: Color(red: 0.8, green: 0.5, blue: 1.0))
                TimeUnitView(value: minutes, unit: "分", color: Color(red: 1.0, green: 0.7, blue: 0.4))
                TimeUnitView(value: seconds, unit: "秒", color: Color(red: 0.5, green: 0.9, blue: 0.6))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Time Unit View
struct TimeUnitView: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Study Statistics Card
struct StudyStatisticsCard: View {
    let practiceQuestions: Int
    let averageAccuracy: Double
    let studyDuration: TimeInterval
    let completedExams: Int
    let errorCount: Int
    
    private var studyHours: Int {
        Int(studyDuration / 3600)
    }
    
    private var studyMinutes: Int {
        Int((studyDuration.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                
                Text("学习统计")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Statistics Grid (2 columns)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatisticItemView(
                        icon: "checkmark.circle.fill",
                        title: "已练习题目",
                        value: "\(practiceQuestions)",
                        color: Color(red: 0.4, green: 0.7, blue: 1.0)
                    )
                    
                    StatisticItemView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "平均正确率",
                        value: String(format: "%.1f%%", averageAccuracy),
                        color: Color(red: 0.5, green: 0.9, blue: 0.6)
                    )
                }
                
                HStack(spacing: 12) {
                    StatisticItemView(
                        icon: "clock.fill",
                        title: "练习时长",
                        value: "\(studyHours)h \(studyMinutes)m",
                        color: Color(red: 1.0, green: 0.7, blue: 0.4)
                    )
                    
                    StatisticItemView(
                        icon: "doc.text.fill",
                        title: "完成考试",
                        value: "\(completedExams)",
                        color: Color(red: 0.8, green: 0.5, blue: 1.0)
                    )
                }
                
                // Error count (full width, clickable)
                NavigationLink(destination: WrongQuestionListView()) {
                    StatisticItemView(
                        icon: "exclamationmark.triangle.fill",
                        title: "错题总数",
                        value: "\(errorCount)",
                        color: Color(red: 1.0, green: 0.4, blue: 0.4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Statistic Item View
struct StatisticItemView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.12))
        )
    }
}

#Preview {
    HomeView()
}
