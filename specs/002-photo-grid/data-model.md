# Photo Grid Display Data Model

## Core View Models

### PhotoGridItem
Represents a single photo in the grid with loading and selection state.

```swift
@Observable
final class PhotoGridItem: Identifiable {
    let id: String                    // PHAsset.localIdentifier
    let asset: PHAsset               // Source asset from Photos library
    var thumbnail: UIImage?          // Loaded thumbnail (nil until loaded)
    var isSelected: Bool = false     // Selection state
    var loadingState: LoadingState = .pending
    
    // Computed properties
    var creationDate: Date? { asset.creationDate }
    var mediaType: PHAssetMediaType { asset.mediaType }
    var isFromCloud: Bool { 
        asset.sourceType == .typeCloudShared || 
        (asset.resourcesFor(.image).isEmpty && asset.resourcesFor(.video).isEmpty)
    }
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
    }
}

enum LoadingState: Equatable {
    case pending        // Not yet requested
    case loading        // Currently loading thumbnail
    case loaded         // Successfully loaded
    case failed(Error)  // Failed to load
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
```

### PhotoGridViewModel
Main view model managing the photo grid state and operations.

```swift
@MainActor
@Observable
final class PhotoGridViewModel {
    // Grid state
    private(set) var photos: [PhotoGridItem] = []
    private(set) var isLoading = false
    private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    // Selection state
    private(set) var selectedPhotos: Set<String> = []
    var isSelectionMode = false
    
    // Error handling
    private(set) var error: PhotoGridError?
    
    // Dependencies
    private let photoLoadingService: PhotoLoadingServiceProtocol
    private let selectionService: SelectionServiceProtocol
    
    // Computed properties
    var selectedCount: Int { selectedPhotos.count }
    var hasPhotos: Bool { !photos.isEmpty }
    var canSelectAll: Bool { !photos.isEmpty && selectedPhotos.count < photos.count }
    
    init(photoLoadingService: PhotoLoadingServiceProtocol,
         selectionService: SelectionServiceProtocol) {
        self.photoLoadingService = photoLoadingService
        self.selectionService = selectionService
    }
    
    // Public interface
    func requestPhotosAccess() async
    func loadPhotos() async
    func loadThumbnail(for item: PhotoGridItem) async
    func toggleSelection(for item: PhotoGridItem)
    func selectAll()
    func clearSelection()
    func enterSelectionMode()
    func exitSelectionMode()
}
```

### SelectionState
Encapsulates photo selection logic and state.

```swift
@Observable
final class SelectionState {
    private(set) var selectedIds: Set<String> = []
    var isActive = false
    
    var count: Int { selectedIds.count }
    var isEmpty: Bool { selectedIds.isEmpty }
    var hasSelection: Bool { !selectedIds.isEmpty }
    
    func toggle(_ id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
    
    func select(_ id: String) {
        selectedIds.insert(id)
    }
    
    func deselect(_ id: String) {
        selectedIds.remove(id)
    }
    
    func selectAll(_ ids: [String]) {
        selectedIds = Set(ids)
    }
    
    func clear() {
        selectedIds.removeAll()
    }
    
    func isSelected(_ id: String) -> Bool {
        selectedIds.contains(id)
    }
}
```

## Service Protocols

### PhotoLoadingServiceProtocol
Handles efficient loading of photo thumbnails from PhotoKit.

```swift
@MainActor
protocol PhotoLoadingServiceProtocol: ObservableObject {
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchPhotos() async throws -> [PHAsset]
    func loadThumbnail(for asset: PHAsset, size: CGSize) async throws -> UIImage
    func preloadThumbnails(for assets: [PHAsset], size: CGSize) async
    func cancelThumbnailLoading(for asset: PHAsset)
}
```

### SelectionServiceProtocol
Manages photo selection state and operations.

```swift
protocol SelectionServiceProtocol {
    var selectionState: SelectionState { get }
    
    func toggleSelection(for photoId: String)
    func selectAll(photoIds: [String])
    func clearSelection()
    func enterSelectionMode()
    func exitSelectionMode()
}
```

## Configuration Types

### GridConfiguration
Controls grid layout and behaviour across platforms.

```swift
struct GridConfiguration {
    let columns: GridColumns
    let spacing: CGFloat
    let thumbnailSize: CGSize
    let aspectRatio: CGFloat
    
    static let iPhone = GridConfiguration(
        columns: .adaptive(minimum: 120),
        spacing: 2,
        thumbnailSize: CGSize(width: 120, height: 120),
        aspectRatio: 1.0
    )
    
    static let iPad = GridConfiguration(
        columns: .adaptive(minimum: 150),
        spacing: 4,
        thumbnailSize: CGSize(width: 150, height: 150),
        aspectRatio: 1.0
    )
    
    static let macOS = GridConfiguration(
        columns: .adaptive(minimum: 180),
        spacing: 6,
        thumbnailSize: CGSize(width: 180, height: 180),
        aspectRatio: 1.0
    )
}

enum GridColumns {
    case fixed(Int)
    case adaptive(minimum: CGFloat)
}
```

### ThumbnailCacheConfiguration
Controls thumbnail caching behaviour for performance.

```swift
struct ThumbnailCacheConfiguration {
    let memoryCapacity: Int          // Number of thumbnails to keep in memory
    let diskCapacity: Int            // Number of thumbnails to cache on disk
    let maxConcurrentLoads: Int      // Maximum concurrent thumbnail requests
    let prefetchCount: Int           // Number of off-screen thumbnails to preload
    
    static let `default` = ThumbnailCacheConfiguration(
        memoryCapacity: 200,
        diskCapacity: 1000,
        maxConcurrentLoads: 10,
        prefetchCount: 50
    )
    
    static let lowMemory = ThumbnailCacheConfiguration(
        memoryCapacity: 100,
        diskCapacity: 500,
        maxConcurrentLoads: 5,
        prefetchCount: 25
    )
}
```

## Error Types

### PhotoGridError
Comprehensive error handling for photo grid operations.

```swift
enum PhotoGridError: LocalizedError, Equatable {
    case authorizationDenied
    case authorizationRestricted
    case photosUnavailable
    case thumbnailLoadFailed(String)
    case networkUnavailable
    case insufficientStorage
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Photos access denied. Please grant permission in Settings."
        case .authorizationRestricted:
            return "Photos access restricted by device policy."
        case .photosUnavailable:
            return "Photos library is currently unavailable."
        case .thumbnailLoadFailed(let assetId):
            return "Failed to load thumbnail for photo: \(assetId)"
        case .networkUnavailable:
            return "Network unavailable for iCloud photo access."
        case .insufficientStorage:
            return "Insufficient storage to load photos from iCloud."
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}
```

## State Management

### Grid Loading States
```swift
enum GridLoadingState: Equatable {
    case initial           // Before any loading attempt
    case requestingAccess  // Requesting Photos permission
    case loading           // Loading photo assets
    case loaded(Int)       // Successfully loaded (count of photos)
    case empty             // No photos in library
    case error(PhotoGridError) // Failed to load
    
    var isLoading: Bool {
        switch self {
        case .requestingAccess, .loading:
            return true
        default:
            return false
        }
    }
}
```

### Performance Tracking
```swift
struct GridPerformanceMetrics {
    var thumbnailLoadTime: TimeInterval = 0
    var scrollingFrameRate: Double = 0
    var memoryUsage: Int64 = 0
    var photosLoaded: Int = 0
    
    mutating func recordThumbnailLoad(duration: TimeInterval) {
        thumbnailLoadTime = (thumbnailLoadTime + duration) / 2
    }
    
    mutating func recordFrameRate(_ fps: Double) {
        scrollingFrameRate = (scrollingFrameRate + fps) / 2
    }
}
```

This data model provides a clean, observable foundation for the photo grid feature while maintaining SwiftUI best practices and efficient PhotoKit integration.
