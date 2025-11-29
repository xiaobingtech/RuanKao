//
//  User.swift
//  RuanKao
//
//  Created by fandong on 2025/11/28.
//

import Foundation
import SwiftData

@Model
final class User {
    var userId: String = ""
    var username: String = ""
    var createdAt: Date = Date()
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
        self.createdAt = Date()
    }
}
