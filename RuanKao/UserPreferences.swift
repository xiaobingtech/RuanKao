//
//  UserPreferences.swift
//  RuanKao
//
//  Created by fandong on 2025/11/24.
//

import Foundation
import SwiftUI
internal import Combine

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    // MARK: - Published Properties
    @Published var selectedCourseId: Int? {
        didSet {
            UserDefaults.standard.set(selectedCourseId, forKey: "selectedCourseId")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var selectedCourseName: String? {
        didSet {
            UserDefaults.standard.set(selectedCourseName, forKey: "selectedCourseName")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var userFullName: String? {
        didSet {
            UserDefaults.standard.set(userFullName, forKey: "userFullName")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var userEmail: String? {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Computed Properties
    var isAdvancedCourse: Bool {
        return selectedCourseId == 3
    }
    
    var isIntermediateCourse: Bool {
        return selectedCourseId == 4
    }
    
    var courseDisplayName: String {
        switch selectedCourseId {
        case 3:
            return "高项"
        case 4:
            return "中项"
        default:
            return "未选择"
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Load persisted values
        if let courseId = UserDefaults.standard.object(forKey: "selectedCourseId") as? Int {
            self.selectedCourseId = courseId
        }
        
        self.selectedCourseName = UserDefaults.standard.string(forKey: "selectedCourseName")
        self.userFullName = UserDefaults.standard.string(forKey: "userFullName")
        self.userEmail = UserDefaults.standard.string(forKey: "userEmail")
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    // MARK: - Course Selection
    func selectCourse(id: Int, name: String) {
        self.selectedCourseId = id
        self.selectedCourseName = name
    }
    
    func selectAdvancedCourse() {
        selectCourse(id: 3, name: "信息系统项目管理师")
    }
    
    func selectIntermediateCourse() {
        selectCourse(id: 4, name: "系统集成项目管理工程师")
    }
    
    // MARK: - User Data
    func setUserData(fullName: String?, email: String?) {
        self.userFullName = fullName
        self.userEmail = email
    }
    
    func clearUserData() {
        self.userFullName = nil
        self.userEmail = nil
    }
    
    // MARK: - Authentication
    func login() {
        self.isLoggedIn = true
    }
    
    func logout() {
        self.isLoggedIn = false
    }
    
    func clearAll() {
        self.selectedCourseId = nil
        self.selectedCourseName = nil
        self.userFullName = nil
        self.userEmail = nil
        self.isLoggedIn = false
    }
}
