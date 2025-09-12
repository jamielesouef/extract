# Photo Grid Display – Product & Technical Spec (v0.1)

*Last updated: 9 September 2025 (AET)*

## 1. Overview

Photo Grid Display is a focused feature that loads photos from iCloud Photos library and displays them in a responsive grid layout across iOS, iPadOS, and macOS. This serves as the foundation for photo browsing and selection in the larger Photos Exporter app.

### Goals
- Fast, responsive photo grid that works across all Apple platforms
- Efficient loading of thumbnails from iCloud Photos
- Smooth scrolling performance with lazy loading
- Basic photo selection capabilities
- Proper Photos permissions handling

### Non-Goals
- Export functionality (future spec)
- Archive management (future spec)
- Background processing (future spec)
- Advanced filtering/search (future spec)

## 2. Target Platforms & Tech

- **Platforms**: iOS 18+, iPadOS 18+, macOS 26+ (Apple silicon first-class)
- **Language**: Swift 6 (strict concurrency)
- **UI Framework**: SwiftUI with LazyVGrid
- **Photos Access**: PhotoKit framework for library access
- **Performance**: 60fps scrolling, <200ms thumbnail load times

## 3. Primary User Flows

### Flow 1: First Launch - Grant Photos Access
1. User launches app
2. App requests Photos library access
3. User grants permission in system dialogue
4. App loads and displays photo grid

### Flow 2: Browse Photos Grid
1. User sees grid of photo thumbnails (3-4 columns on phone, more on iPad/Mac)
2. User scrolls through photos with smooth performance
3. Thumbnails load as they come into view (lazy loading)
4. User can tap photos to see larger preview (simple modal)

### Flow 3: Basic Selection
1. User taps "Select" button to enter selection mode
2. User taps photos to select/deselect (visual feedback)
3. Selected count shows in UI
4. User can "Select All" or "Clear Selection"
5. User exits selection mode

## 4. Technical Requirements

### Performance Targets
- Grid scrolling: 60fps sustained
- Thumbnail loading: <200ms per image
- Memory usage: <500MB for 10,000 photo library
- Responsive grid that adapts to screen size changes

### Photos Integration
- Request appropriate permissions (read-only access)
- Load thumbnails efficiently using PHCachingImageManager
- Handle iCloud photo downloads gracefully
- Respect user's "Optimize Storage" settings

### Platform Adaptations
- **iOS**: 3-column grid, navigation bar controls
- **iPadOS**: 4-6 column grid (based on size class), toolbar
- **macOS**: Dynamic columns based on window width, menu bar integration

## 5. UI/UX Specifications

### Grid Layout
- Adaptive column count based on screen width
- Square aspect ratio thumbnails with subtle borders
- Consistent spacing and margins
- Pull-to-refresh gesture support

### Selection State
- Checkmark overlay on selected photos
- Selection count in navigation/toolbar
- Batch actions available when items selected
- Visual distinction between selected/unselected

### Loading States
- Skeleton loading for initial grid population
- Progressive thumbnail loading with placeholders
- Activity indicators for iCloud downloads
- Error states for failed loads

## 6. Success Criteria

### Functional
- All photos from library display correctly in grid
- Smooth scrolling performance maintained
- Selection state works reliably
- Proper permission handling and error states

### Performance
- 60fps scrolling on target devices
- Memory usage stays under 500MB
- No crashes with large photo libraries (10,000+ photos)
- Quick app launch (<3 seconds to show first photos)

### User Experience
- Intuitive grid navigation
- Responsive to device orientation changes
- Accessible (VoiceOver support)
- Consistent behaviour across platforms

## 7. Future Considerations

This focused spec establishes the foundation for:
- Export job creation (select photos → export)
- Advanced filtering and search
- Album-based browsing
- Smart collections and favourites

The grid component should be designed with these future extensions in mind, but not implement them in this phase.
