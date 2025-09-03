# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Extract is a SwiftUI-based macOS/iOS app for exporting photos and videos from iCloud Photo Library to various destinations (local drives, NAS, cloud storage like S3). The app targets macOS 26, iOS 26, and iPadOS 26.

## Architecture

### Core Components

- **App Entry Point**: `extractApp.swift` - Main app entry point using SwiftUI App lifecycle
- **Navigation**: Uses `NavigationSplitView` architecture with sidebar and detail view
- **State Management**: 
  - `AppState` - Global app state including navigation path and window size
  - `MediaStore` - Observable class managing Photos library access and asset loading
- **Data Persistence**: SwiftData with `MediaItem` model for tracking backup status
- **Photo Library Integration**: Uses PhotoKit (`PHAsset`, `PHPhotoLibrary`) for iCloud Photos access

### Key Models

- **MediaItem**: SwiftData model tracking individual media items with backup status
- **MediaStore**: Main data controller for Photos library integration
- **NavigationOptions**: Enum defining app navigation structure (New Photos, Backed up Photos)

### View Structure

- `ExtractSplitView`: Root split view container
- `PhotosView`: Main photo browsing interface
- `BackupsView`: View for backed up photos
- `FailedPhotosAccessView`: Permissions error state

## Development

### Building and Running

The project uses standard Xcode build system with Makefile integration:

**Using Makefile (Recommended):**
- `make build` - Build with SwiftLint checks
- `make run` - Build and launch the app
- `make lint` - Run SwiftLint only
- `make clean` - Clean build artifacts
- `make help` - Show all available commands

**Using Xcode:**
- Open `extract.xcodeproj` in Xcode
- Build and run with Cmd+R
- No external package managers (SPM, CocoaPods, Carthage) are used

### Key Requirements

- Xcode 16 or later
- macOS 26 / iOS 26 / iPadOS 26 deployment target
- Photos framework permissions required
- Network permissions for NAS/cloud features

### Important Patterns

- All UI state management uses SwiftUI's `@Observable` macro
- PhotoKit operations are performed on background queues via `Task.detached`
- Models use SwiftData for persistence with in-memory storage during development
- Navigation uses `NavigationPath` for programmatic navigation

### Code Conventions

- File headers include creation date and author (Jamie Le Souef)
- SwiftUI view files use `#Preview` for previews
- Environment objects passed via `.environment()` modifier
- Async operations use modern Swift concurrency (async/await, Task)