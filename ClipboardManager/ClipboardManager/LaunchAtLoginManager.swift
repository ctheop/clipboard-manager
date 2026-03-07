//
//  LaunchAtLoginManager.swift
//  ClipboardManager
//
//  Created by Theodor Plümpe on 24.02.26.
//

import Foundation
import Combine
import ServiceManagement

class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            do {
                if isEnabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Launch at Login Fehler: \(error)")
            }
        }
    }
    
    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
