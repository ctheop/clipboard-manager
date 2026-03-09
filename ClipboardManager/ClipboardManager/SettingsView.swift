//
//  SettingsView.swift
//  ClipboardManager
//
//  Created by Theodor Plümpe on 24.02.26.
// Datei enthält die Einstellungen der App, wie z.B. die Anzahl der gespeicherten Einträge, das Ignorieren von Duplikaten und das Ausschließen von Passwörtern.

import Foundation
import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
  @ObservedObject var launchAtLogin = LaunchAtLoginManager()
  @AppStorage("maxItems") var maxItems: Int = 50
  @AppStorage("ignoreDuplicates") var ignoreDuplicates: Bool = true
  @AppStorage("excludePasswords") var excludePasswords: Bool = true

  var body: some View {
    Form {
      Section("Allgemein") {
        Toggle("automatic Launch at Login", isOn: $launchAtLogin.isEnabled)

        KeyboardShortcuts.Recorder("Hotkey zum Öffnen", name: .toggleClipboard)
      }

      Section("Verlauf") {
        Stepper("Max. Einträge: \(maxItems)", value: $maxItems, in: 10...200, step: 10)
        Toggle("Duplikate ignorieren", isOn: $ignoreDuplicates)
        Toggle("Passwörter ausschließen", isOn: $excludePasswords)
      }

      Section("Daten") {
        Button("Komplette History löschen", role: .destructive) {
          UserDefaults.standard.removeObject(forKey: "clipboard_history")
        }

        Button("App beenden", role: .destructive) {
          NSApp.terminate(nil)
        }
      }
    }
    .formStyle(.grouped)
    .frame(width: 360, height: 300)
    .padding()
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        NSApp.windows
          .filter { $0.canBecomeKey && !$0.title.isEmpty }
          .last?
          .level = .floating
      }
    }
  }
}
