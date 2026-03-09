# Clipboard Manager

A lightweight, native macOS clipboard manager that lives in your menu bar. It automatically tracks your clipboard history and lets you quickly search, browse, and re-copy anything you've copied before.

## Features

- **Clipboard history** – automatically captures text, images, and file paths as you copy them
- **Instant search** – filter your history in real time by typing in the search bar
- **Favorites** – star any item to pin it and protect it from automatic cleanup
- **Multi-type support** – handles plain text, images, and file URLs; clickable links are detected automatically
- **Persistent history** – text and file entries survive app restarts (stored in `UserDefaults`)
- **Menu bar integration** – unobtrusive status bar icon; click to open the history popover
- **Global hotkey** – open the popover from anywhere with a fully customizable keyboard shortcut
- **Duplicate filtering** – optional deduplication keeps your list clean
- **Password exclusion** – optionally skips clipboard content marked as concealed (e.g. from password managers)
- **Configurable history size** – choose between 10 and 200 entries (default: 50)
- **Launch at Login** – start automatically when you log in to macOS

## Requirements

| Requirement | Minimum version |
| ----------- | --------------- |
| macOS       | 13.0 Ventura    |
| Xcode       | 15.0            |
| Swift       | 5.9             |

## Installation

### Download a release

1. Go to the [Releases](../../releases) page.
2. Download the latest `.dmg` or `.zip` archive.
3. Open the archive and drag **ClipboardManager.app** to your `/Applications` folder.
4. Launch the app. macOS may ask you to confirm opening a downloaded application — click **Open**.

On first launch macOS will request permission to monitor input if required; grant it in **System Settings → Privacy & Security**.

### Build from source

See the [Building from source](#building-from-source) section below.

## Usage

### Opening clipboard history

| Method                                       | Action                                    |
| -------------------------------------------- | ----------------------------------------- |
| Click the **clipboard icon** in the menu bar | Opens the history popover                 |
| Press the configured **global hotkey**       | Toggles the history popover from anywhere |

The default hotkey is not set on first launch; you can assign one in **Settings → General → Hotkey**.

### Working with history items

| Action                        | How                                                        |
| ----------------------------- | ---------------------------------------------------------- |
| **Re-copy an item**           | Click it in the list                                       |
| **Open a URL**                | Click the blue link text                                   |
| **Star / unstar a favourite** | Click the ★ button on the right of any row                 |
| **Delete a single item**      | Right-click → **Delete**                                   |
| **Toggle favourites filter**  | Click the ★ icon in the header toolbar                     |
| **Search**                    | Type in the search bar at the top of the popover           |
| **Clear history**             | Click the 🗑 icon in the header (favourites are preserved) |

### Context menu

Right-click any item to access:

- **Add to Favourites** / **Remove from Favourites**
- **Delete**

## Settings

Open **Settings** by clicking the ⚙ icon in the popover header, or via the standard macOS menu bar (**ClipboardManager → Settings…**).

### General

| Setting             | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| **Launch at Login** | Automatically start ClipboardManager when you log in                  |
| **Hotkey**          | The global keyboard shortcut that opens the clipboard history popover |

### History

| Setting               | Default | Description                                                                          |
| --------------------- | ------- | ------------------------------------------------------------------------------------ |
| **Max entries**       | 50      | Maximum number of non-favourite items kept in history (10 – 200)                     |
| **Ignore duplicates** | On      | Skip adding an item if it already exists in the history                              |
| **Exclude passwords** | On      | Ignore clipboard changes flagged as `ConcealedType` (used by most password managers) |

### Data

| Action                     | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| **Clear complete history** | Permanently deletes all stored history from `UserDefaults` |
| **Quit app**               | Terminates the application                                 |

## Building from source

### 1. Clone the repository

```bash
git clone https://github.com/ctheop/clipboard-manager.git
cd clipboard-manager
```

### 2. Open the Xcode project

```bash
open ClipboardManager/ClipboardManager.xcodeproj
```

### 3. Resolve Swift Package dependencies

Xcode resolves the [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) dependency automatically when the project is opened. If it does not, go to **File → Packages → Resolve Package Versions**.

### 4. Build and run

- **Build:** `⌘ B`
- **Run:** `⌘ R`
- **Test:** `⌘ U`

## Project structure

```
ClipboardManager/
├── ClipboardManager/                   # Application source
│   ├── ClipboardManagerApp.swift       # App entry point and AppDelegate (menu bar + hotkey)
│   ├── ContentView.swift               # Main history UI (search, list, favourites)
│   ├── ClipboardService.swift          # Clipboard monitoring, history management, persistence
│   ├── Item.swift                      # ClipboardItem data model
│   ├── SettingsView.swift              # Settings / preferences window
│   ├── KeyboardShortcuts+Extensions.swift  # Global hotkey name definition
│   ├── LaunchAtLoginManager.swift      # Launch-at-login via ServiceManagement
│   └── Assets.xcassets/               # App icon and asset catalogue
├── ClipboardManagerTests/              # Unit tests
└── ClipboardManagerUITests/            # UI tests
```

## Architecture overview

```
User Interaction (hotkey / menu bar click)
           │
   ClipboardManagerApp (AppDelegate)
           │
   ContentView (SwiftUI view) ◄──── ClipboardService (ObservableObject)
           │                                   │
   Render history list               Poll NSPasteboard every 0.5 s
           │                                   │
   Copy item back to clipboard       Persist to UserDefaults
```

The app follows a lightweight **MVVM** pattern:

- **View layer** – `ContentView` and `SettingsView` (SwiftUI)
- **Service layer** – `ClipboardService` is the single source of truth (Combine `@Published`)
- **Data model** – `ClipboardItem` struct with four content types: `text`, `image`, `fileURL`, `unknown`

## Running on macOS

macOS may prevent the app from running due to security settings.
To allow it:

1. Right-click the app and select "Open"
2. Click "Open" in the dialog that appears

Or in Terminal:

```bash
sudo xattr -rd com.apple.quarantine ~/Downloads/clipboard-manager.app

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository and create a new branch from `main`.
2. Make your changes, ensuring existing tests still pass (`⌘ U` in Xcode).
3. Add tests for any new behaviour.
4. Open a pull request describing what you changed and why.

Please keep pull requests focused — one feature or fix per PR makes review much easier.

## License

This project is currently unlicensed. See the repository owner for usage terms.
```
