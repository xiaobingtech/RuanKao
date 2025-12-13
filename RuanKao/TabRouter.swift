//
//  TabRouter.swift
//  RuanKao
//
//  Created by GPT on 2025/12/13.
//

import SwiftUI
internal import Combine

enum MainTab: Hashable, Codable {
    case home
    case questionBank
    case profile
}

enum QuestionBankRoute: Hashable, Codable {
    case chapters
    case practiceMode(ChapterInfo)
    case practice(PracticeSession)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case chapter
        case session
    }
    
    private enum RouteType: String, Codable {
        case chapters
        case practiceMode
        case practice
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RouteType.self, forKey: .type)
        switch type {
        case .chapters:
            self = .chapters
        case .practiceMode:
            let chapter = try container.decode(ChapterInfo.self, forKey: .chapter)
            self = .practiceMode(chapter)
        case .practice:
            let session = try container.decode(PracticeSession.self, forKey: .session)
            self = .practice(session)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .chapters:
            try container.encode(RouteType.chapters, forKey: .type)
        case .practiceMode(let chapter):
            try container.encode(RouteType.practiceMode, forKey: .type)
            try container.encode(chapter, forKey: .chapter)
        case .practice(let session):
            try container.encode(RouteType.practice, forKey: .type)
            try container.encode(session, forKey: .session)
        }
    }
}

struct PracticeSession: Hashable, Codable {
    let chapter: ChapterInfo
    let groupNumber: Int
    let mode: PracticeMode
}

@MainActor
final class TabRouter: ObservableObject {    
    @Published var selectedTab: MainTab = .home
    @Published var questionBankPath: [QuestionBankRoute] = []
}


