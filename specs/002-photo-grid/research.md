# Photo Grid Display Research

## PhotoKit Integration Best Practices

### Decision: PHCachingImageManager for Performance
**Rationale**: PHCachingImageManager provides optimal performance for grid-based thumbnail loading with built-in memory management and request prioritization.

**Key Patterns**:
- Use `PHCachingImageManager` for all thumbnail requests
- Pre-cache visible and near-visible thumbnails
- Cancel requests for off-screen items to free resources
- Use appropriate `PHImageRequestOptions` for quality vs speed

**Implementation**:
```swift
let imageManager = PHCachingImageManager()
let options = PHImageRequestOptions()
options.deliveryMode = .opportunistic
options.resizeMode = .fast
options.isNetworkAccessAllowed = true
```

**Alternatives Considered**:
- `PHImageManager.default()` - rejected due to lack of caching control
- Custom caching solution - rejected due to complexity and PhotoKit optimisation

## SwiftUI Grid Performance

### Decision: LazyVGrid with Adaptive Columns
**Rationale**: LazyVGrid provides optimal performance for large photo collections with on-demand view creation and automatic recycling.

**Key Patterns**:
- Use `GridItem(.adaptive(minimum:))` for responsive column count
- Implement `onAppear`/`onDisappear` for thumbnail lifecycle
- Use `@Observable` view models for efficient UI updates
- Leverage `scrollTargetLayout()` for smooth scrolling

**Alternatives Considered**:
- Regular VGrid - rejected due to memory usage with large collections
- Custom grid implementation - rejected due to SwiftUI optimisation benefits

## Swift 6 Concurrency for Photos

### Decision: MainActor for UI, Task.detached for PhotoKit
**Rationale**: PhotoKit operations can be expensive and should not block the main actor, while UI updates must remain on main actor.

**Pattern**:
```swift
@MainActor
func loadThumbnail(for asset: PHAsset) async {
    loadingState = .loading
    
    let thumbnail = await Task.detached {
        // PhotoKit operations off main actor
        return try await loadThumbnailOffMainActor(asset)
    }.value
    
    // UI update back on main actor
    self.thumbnail = thumbnail
    loadingState = .loaded
}
```

**Alternatives Considered**:
- All operations on main actor - rejected due to UI blocking
- Custom actor isolation - rejected due to unnecessary complexity

## Platform Adaptations

### Decision: Single Component with Conditional Layout
**Rationale**: Maintain code sharing while adapting to platform-specific design patterns and capabilities.

**Adaptations**:
- **iOS**: Navigation bar integration, 3-column grid, pull-to-refresh
- **iPadOS**: Toolbar integration, adaptive columns (4-6), larger thumbnails
- **macOS**: Menu bar integration, right-click menus, keyboard navigation

**Implementation Strategy**:
```swift
#if os(iOS)
    let columns = [GridItem(.adaptive(minimum: 120))]
#elseif os(macOS)
    let columns = [GridItem(.adaptive(minimum: 180))]
#endif
```

**Alternatives Considered**:
- Separate views per platform - rejected due to code duplication
- Lowest common denominator - rejected due to poor platform integration

## Memory Management Strategy

### Decision: Aggressive Thumbnail Eviction with Smart Preloading
**Rationale**: Balance memory usage with smooth scrolling by intelligently managing thumbnail cache lifecycle.

**Strategy**:
- Keep thumbnails for visible items + 50 buffer items
- Preload thumbnails for scroll direction
- Use weak references for distant items
- Monitor memory warnings and adjust cache size

**Cache Sizes**:
- iPhone: 200 thumbnails in memory, 500 on disk
- iPad: 300 thumbnails in memory, 750 on disk  
- macOS: 400 thumbnails in memory, 1000 on disk

**Alternatives Considered**:
- Fixed cache size - rejected due to varying device capabilities
- No memory management - rejected due to crash risk with large libraries
