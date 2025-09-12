# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Photos Exporter (formerly Extract) is a privacy-respecting, cross-platform SwiftUI app for exporting photos and videos from iCloud Photo Library to multiple Archive destinations (local folders, NAS via SMB/WebDAV, S3-compatible storage). The app targets macOS 26, iOS 18, and iPadOS 18 with Swift 6 strict concurrency.

## Architecture

### Core Components

- **App Entry Point**: `extractApp.swift` - Main app entry point using SwiftUI App lifecycle
- **Navigation**: Uses `NavigationSplitView` architecture with sidebar and detail view
- **State Management**: 
  - `AppState` - Global app state including navigation path and window size
  - `MediaStore` - Observable class managing Photos library access and asset loading
- **Data Persistence**: SwiftData with comprehensive models for export jobs and integrity tracking
- **Photo Library Integration**: Uses PhotoKit (`PHAsset`, `PHPhotoLibrary`) for iCloud Photos access
- **Export Architecture**: 
  - `PhotosServiceProtocol` - Photos library access and asset retrieval with Swift 6 concurrency
  - `ExportServiceProtocol` - Export job orchestration and queue management
  - `ArchiveServiceProtocol` - Archive configuration and storage backend management
  - `IntegrityServiceProtocol` - Checksum calculation and audit operations
- **Archive Backends**: Pluggable adapters for Folder, NAS (SMB/WebDAV), and S3-compatible storage

### Key Models

- **Legacy Models** (existing):
  - `MediaItem` - SwiftData model tracking individual media items with backup status
  - `MediaStore` - Main data controller for Photos library integration  
  - `NavigationOptions` - Enum defining app navigation structure
- **New Export Models** (Photos Exporter feature):
  - `Archive` - Archive destination configuration (local, NAS, S3)
  - `ExportJob` - Batch export operation with progress tracking
  - `ExportItem` - Individual media item within an export job
  - `ArchiveRecord` - Audit trail of successfully exported items
  - `AuditLog` - Integrity monitoring and verification results

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
- **Swift 6 Concurrency**: Strict actor isolation with `@MainActor` for UI, `@ModelActor` for data, custom actors for I/O
- **Archive Pattern**: Protocol-based adapters for pluggable storage backends
- **Integrity-First**: SHA-256 checksums and audit trails for all exported content
- **Background Processing**: BGProcessingTask integration for long-running exports

### Code Conventions

- File headers include creation date and author (Jamie Le Souef)
- SwiftUI view files use `#Preview` for previews
- Environment objects passed via `.environment()` modifier
- Async operations use modern Swift concurrency (async/await, Task)

## Recent Changes

- 001-photos-exporter: Added Swift 6 + Photos/SwiftData export architecture with NAS/S3 backends
- Build system: Enhanced with SwiftLint to SwiftFormat migration  
- Testing: Added comprehensive unit and integration test suite with Swift Testing
