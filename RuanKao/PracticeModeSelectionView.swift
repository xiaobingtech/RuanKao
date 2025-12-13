//
//  PracticeModeSelectionView.swift
//  RuanKao
//
//  Created by fandong on 2025/11/25.
//

import SwiftUI

enum PracticeMode: String, CaseIterable, Identifiable {
    case simulation = "模拟考试"
    case memorization = "背题模式"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .simulation:
            return "clock.fill"
        case .memorization:
            return "brain.head.profile"
        }
    }
    
    var description: String {
        switch self {
        case .simulation:
            return "限时答题，模拟真实考试环境"
        case .memorization:
            return "自由练习，随时查看答案解析"
        }
    }
}

struct PracticeModeSelectionView: View {
    let chapter: ChapterInfo
    @State private var selectedGroup: Int?
    @State private var selectedMode: PracticeMode?
    @State private var route: PracticeRoute?
    
    private struct PracticeRoute: Identifiable, Hashable {
        let groupNumber: Int
        let mode: PracticeMode
        var id: String { "\(groupNumber)-\(mode.rawValue)" }
    }
    
    var isConfirmEnabled: Bool {
        selectedGroup != nil && selectedMode != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: "gearshape.fill")
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
                    
                    Text(chapter.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 24)
                
                VStack(spacing: 20) {
                    // Question Group Selection
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "选择题组", icon: "list.bullet.rectangle")
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(1...chapter.questionGroupCount, id: \.self) { groupNumber in
                                GroupSelectionCard(
                                    groupNumber: groupNumber,
                                    isSelected: selectedGroup == groupNumber
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedGroup = groupNumber
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Practice Mode Selection
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "练习模式", icon: "square.stack.3d.up")
                        
                        VStack(spacing: 12) {
                            ForEach(PracticeMode.allCases) { mode in
                                ModeSelectionCard(
                                    mode: mode,
                                    isSelected: selectedMode == mode
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedMode = mode
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Confirm Button
                    Button {
                        guard let group = selectedGroup, let mode = selectedMode else { return }
                        // 用 navigationDestination 做“真正懒推”，避免 iOS17 下 NavigationLink 预构建/反复创建 destination
                        route = PracticeRoute(groupNumber: group, mode: mode)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("开始练习")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: isConfirmEnabled ? [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.5, green: 0.3, blue: 0.8)
                                ] : [Color.gray, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(
                            color: isConfirmEnabled ? Color(red: 0.4, green: 0.35, blue: 0.85).opacity(0.3) : Color.clear,
                            radius: 8, x: 0, y: 4
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isConfirmEnabled)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("练习设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $route) { route in
            QuestionPracticeView(
                chapter: chapter,
                groupNumber: route.groupNumber,
                practiceMode: route.mode
            )
        }
    }

}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.85))
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Group Selection Card
struct GroupSelectionCard: View {
    let groupNumber: Int
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? Color(red: 0.3, green: 0.4, blue: 0.9) : .secondary)
                
                Text("第\(groupNumber)组")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          Color(red: 0.3, green: 0.4, blue: 0.9).opacity(0.1) : 
                          Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? 
                        Color(red: 0.3, green: 0.4, blue: 0.9) : 
                        Color.gray.opacity(0.2), 
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Mode Selection Card
struct ModeSelectionCard: View {
    let mode: PracticeMode
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? 
                              LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.5, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ) :
                              LinearGradient(
                                colors: [Color.gray, Color.gray],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Mode Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(mode.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? Color(red: 0.3, green: 0.4, blue: 0.9) : .secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          Color(red: 0.3, green: 0.4, blue: 0.9).opacity(0.1) : 
                          Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? 
                        Color(red: 0.3, green: 0.4, blue: 0.9) : 
                        Color.gray.opacity(0.2), 
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        PracticeModeSelectionView(
            chapter: ChapterInfo(
                name: "第一章 信息化发展",
                questionGroupCount: 3,
                path: "/path/to/chapter"
            )
        )
    }
}
