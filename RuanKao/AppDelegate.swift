//
//  AppDelegate.swift
//  RuanKao
//
//  Created by GPT on 2025/12/13.
//

import UIKit

/// 关闭系统的状态恢复持久化（Scene/State Restoration）。
/// 在某些系统版本/组合（尤其是导航状态包含不可序列化对象时），保存恢复信息可能触发断言导致“启动即崩”。
/// 如后续确实需要恢复能力，可以改为让所有路由/状态都可 Codable 后再开启。
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        false
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        false
    }
}


