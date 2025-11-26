//
//  HomeView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // Countdown timer state
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    // SwiftData query for wrong questions
    @Query private var wrongQuestions: [WrongQuestion]
    
    // Study statistics (mock data, can be replaced with actual data from UserDefaults or database)
    @State private var practiceQuestions: Int = 1234
    @State private var averageAccuracy: Double = 78.5
    @State private var studyDuration: TimeInterval = 14580 // in seconds
    @State private var completedExams: Int = 15
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Countdown Section
                    CountdownCard(timeRemaining: timeRemaining)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Study Statistics Section
                    StudyStatisticsCard(
                        practiceQuestions: practiceQuestions,
                        averageAccuracy: averageAccuracy,
                        studyDuration: studyDuration,
                        completedExams: completedExams,
                        errorCount: wrongQuestions.count
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("首页")
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
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
        let targetDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 9, minute: 0))!
        let now = Date()
        timeRemaining = targetDate.timeIntervalSince(now)
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    let timeRemaining: TimeInterval
    
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
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .semibold))
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
                
                Text("考试倒计时")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Target Date
            HStack {
                Text("目标日期：2026年5月24日")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Countdown Display
            HStack(spacing: 12) {
                TimeUnitView(value: days, unit: "天", color: .blue)
                
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.secondary)
                
                TimeUnitView(value: hours, unit: "时", color: .purple)
                
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.secondary)
                
                TimeUnitView(value: minutes, unit: "分", color: .orange)
                
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.secondary)
                
                TimeUnitView(value: seconds, unit: "秒", color: .green)
            }
            .padding(.vertical, 8)
        }
        .padding(20)
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
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(minWidth: 60)
            
            Text(unit)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .fixedSize(horizontal: true, vertical: false)
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
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.9),
                                Color(red: 0.3, green: 0.5, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("学习统计")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Statistics Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatisticItemView(
                        icon: "checkmark.circle.fill",
                        title: "已练习题目",
                        value: "\(practiceQuestions)",
                        color: .blue
                    )
                    
                    StatisticItemView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "平均正确率",
                        value: String(format: "%.1f%%", averageAccuracy),
                        color: .green
                    )
                }
                
                HStack(spacing: 12) {
                    StatisticItemView(
                        icon: "clock.fill",
                        title: "练习时长",
                        value: "\(studyHours)h \(studyMinutes)m",
                        color: .orange
                    )
                    
                    StatisticItemView(
                        icon: "doc.text.fill",
                        title: "完成考试",
                        value: "\(completedExams)",
                        color: .purple
                    )
                }
                
                // Error count (full width, clickable)
                NavigationLink(destination: WrongQuestionListView()) {
                    StatisticItemView(
                        icon: "exclamationmark.triangle.fill",
                        title: "错题总数",
                        value: "\(errorCount)",
                        color: .red
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
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
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.08))
        )
    }
}

#Preview {
    HomeView()
}
