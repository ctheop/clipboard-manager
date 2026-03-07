import SwiftUI

struct ContentView: View {
    @StateObject private var service = ClipboardService()
    @State private var searchText = ""
    @State private var showFavoritesOnly = false

    var filteredHistory: [ClipboardItem] {
        let base = showFavoritesOnly
            ? service.history.filter { $0.isFavorite }
            : service.history
        if searchText.isEmpty { return base }
        return base.filter { $0.displayTitle.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text("Clipboard")
                    .font(.headline)
                Spacer()
                
                SettingsLink {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)


                Toggle(isOn: $showFavoritesOnly) {
                    Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                }
                .toggleStyle(.button)
                .buttonStyle(.plain)
                .foregroundStyle(showFavoritesOnly ? .yellow : .secondary)
                .help("Nur Favoriten anzeigen")

                Button(role: .destructive) {
                    service.clearHistory()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
                .help("History löschen (Favoriten bleiben)")
            }
            .padding(10)

            // Suchfeld
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Suchen...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 10)

            Divider().padding(.top, 8)

            // Liste
            if filteredHistory.isEmpty {
                Spacer()
                Text(searchText.isEmpty ? "Keine Einträge." : "Keine Treffer.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(filteredHistory) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.typeIcon)
                            .frame(width: 16)
                            .foregroundStyle(.secondary)
                        Group {
                                    switch item.type {
                                    case .image(let img):
                                        Image(nsImage: img)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 60)
                                            .cornerRadius(6)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    case .text(let str):
                                        // URL-Erkennung
                                        if let url = URL(string: str), url.scheme == "https" || url.scheme == "http" {
                                            Link(str, destination: url)
                                                .lineLimit(2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        } else {
                                            Text(str)
                                                .lineLimit(2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }

                                    case .fileURL(let url):
                                        Text(url.lastPathComponent)
                                            .lineLimit(2)
                                            .foregroundStyle(.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    case .unknown(let str):
                                        Text(str)
                                            .lineLimit(2)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }


                        Button {
                            service.toggleFavorite(item)
                        } label: {
                            Image(systemName: item.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(item.isFavorite ? .yellow : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.isFavorite
                                  ? Color.yellow.opacity(0.08)
                                  : Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    )
                    .onTapGesture { service.copyBack(item) }
                    .contextMenu {
                        Button {
                            service.toggleFavorite(item)
                        } label: {
                            Label(item.isFavorite ? "Aus Favoriten entfernen" : "Zu Favoriten",
                                  systemImage: item.isFavorite ? "star.slash" : "star")
                        }
                        Divider()
                        Button(role: .destructive) {
                            service.delete(item)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 340, height: 460)
    }
}
