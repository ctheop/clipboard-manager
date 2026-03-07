import AppKit
import Combine
import SwiftUI

class ClipboardService: ObservableObject {
    @Published var history: [ClipboardItem] = []

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private let storageKey = "clipboard_history"

    @AppStorage("maxItems") private var maxItems: Int = 50
    @AppStorage("ignoreDuplicates") private var ignoreDuplicates: Bool = true
    @AppStorage("excludePasswords") private var excludePasswords: Bool = true

    init() {
        lastChangeCount = pasteboard.changeCount
        loadHistory()
        startMonitoring()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
    }

    private func checkForChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        let date = Date()

        // ✅ 1. Bild zuerst
        if let image = NSImage(pasteboard: pasteboard) {
            if ignoreDuplicates && history.contains(where: {
                if case .image(let prev) = $0.type {
                    return prev.size == image.size &&
                           prev.tiffRepresentation?.count == image.tiffRepresentation?.count
                }
                return false
            }) { return }

            let item = ClipboardItem(date: date, type: .image(image))
            DispatchQueue.main.async {
                self.history.insert(item, at: 0)
                self.trimHistory()
            }
            return
        }

        // ✅ 2. Text
        if let text = pasteboard.string(forType: .string) {
            if excludePasswords,
               pasteboard.types?.contains(.init("org.nspasteboard.ConcealedType")) == true {
                return
            }
            if ignoreDuplicates && history.contains(where: {
                if case .text(let t) = $0.type { return t == text }
                return false
            }) { return }

            let item = ClipboardItem(date: date, type: .text(text))
            DispatchQueue.main.async {
                self.history.insert(item, at: 0)
                self.trimHistory()
                self.saveHistory()
            }
            return
        }

        // ✅ 3. File-URL
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
           let url = urls.first {
            if ignoreDuplicates && history.contains(where: {
                if case .fileURL(let u) = $0.type { return u == url }
                return false
            }) { return }

            let item = ClipboardItem(date: date, type: .fileURL(url))
            DispatchQueue.main.async {
                self.history.insert(item, at: 0)
                self.trimHistory()
                self.saveHistory()
            }
            return
        }
    }

    private func trimHistory() {
        let nonFavorites = history.filter { !$0.isFavorite }
        if nonFavorites.count > maxItems {
            let excess = nonFavorites.count - maxItems
            var removed = 0
            history = history.filter { item in
                if !item.isFavorite && removed < excess {
                    removed += 1
                    return false
                }
                return true
            }
        }
    }

    func toggleFavorite(_ item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history[index].isFavorite.toggle()
            saveHistory()
        }
    }

    func delete(_ item: ClipboardItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll { !$0.isFavorite }
        saveHistory()
    }

    func copyBack(_ item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.type {
        case .text(let str): pasteboard.setString(str, forType: .string)
        case .image(let img): pasteboard.writeObjects([img])
        case .fileURL(let url): pasteboard.writeObjects([url as NSURL])
        case .unknown: break
        }
    }

    // MARK: - Persistenz

    private func saveHistory() {
        let saveable = history.compactMap { item -> [String: String]? in
            switch item.type {
            case .text(let str):
                return ["type": "text", "value": str,
                        "date": ISO8601DateFormatter().string(from: item.date),
                        "favorite": item.isFavorite ? "1" : "0"]
            case .fileURL(let url):
                return ["type": "fileURL", "value": url.absoluteString,
                        "date": ISO8601DateFormatter().string(from: item.date),
                        "favorite": item.isFavorite ? "1" : "0"]
            default:
                return nil
            }
        }
        UserDefaults.standard.set(saveable, forKey: storageKey)
    }

    private func loadHistory() {
        guard let saved = UserDefaults.standard.array(forKey: storageKey) as? [[String: String]] else { return }
        let formatter = ISO8601DateFormatter()
        history = saved.compactMap { dict in
            guard let type = dict["type"],
                  let value = dict["value"],
                  let dateStr = dict["date"],
                  let date = formatter.date(from: dateStr) else { return nil }
            let isFav = dict["favorite"] == "1"
            switch type {
            case "text":
                var item = ClipboardItem(date: date, type: .text(value))
                item.isFavorite = isFav
                return item
            case "fileURL":
                guard let url = URL(string: value) else { return nil }
                var item = ClipboardItem(date: date, type: .fileURL(url))
                item.isFavorite = isFav
                return item
            default: return nil
            }
        }
    }
}
