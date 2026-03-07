import AppKit

struct ClipboardItem: Identifiable {
    let id = UUID()
    let date: Date
    let type: ItemType
    var isFavorite: Bool = false

    enum ItemType {
        case text(String)
        case image(NSImage)
        case fileURL(URL)
        case unknown(String)
    }

    var displayTitle: String {
        switch type {
        case .text(let str): return str
        case .image: return "Bild"
        case .fileURL(let url): return url.lastPathComponent
        case .unknown(let t): return t
        }
    }

    var typeIcon: String {
        switch type {
        case .text: return "doc.text"
        case .image: return "photo"
        case .fileURL: return "folder"
        case .unknown: return "questionmark"
        }
    }
}
