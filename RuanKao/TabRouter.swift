//
//  TabRouter.swift
//  RuanKao
//
//  Created by GPT on 2025/12/13.
//

import SwiftUI
internal import Combine

enum MainTab: Hashable {
    case home
    case questionBank
    case profile
}

enum QuestionBankRoute: Hashable {
    case chapters
    case practiceMode(ChapterInfo)
    case practice(PracticeSession)
}

struct PracticeSession: Hashable {
    let chapter: ChapterInfo
    let groupNumber: Int
    let mode: PracticeMode
}

@MainActor
final class TabRouter: ObservableObject {    
    @Published var selectedTab: MainTab = .home
    @Published var questionBankPath = NavigationPath()
}


