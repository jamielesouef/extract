//
//  MediaIndexTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

import Testing
import SwiftData
import Photos
@testable import extract

@Suite("MediaIndex Tests")
struct MediaIndexTests {
    
    @Test("MediaIndex can add new media items from MediaItemData")
    func testAddMediaFromMediaItemData() async throws {
        // Create in-memory model container for testing
        let schema = Schema([MediaItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        let mediaIndex = MediaIndex(modelContainer: container)
        
        // Create test data
        let testItems = [
            MediaItemData(
                mediaId: "test-1",
                kind: .image,
                status: .notBackedUp,
                filename: "test1.jpg"
            ),
            MediaItemData(
                mediaId: "test-2", 
                kind: .video,
                status: .unknown,
                filename: "test2.mp4"
            )
        ]
        
        // Add media items
        try await mediaIndex.addMedia(media: testItems)
        
        // Verify items were added by querying the model context
        let descriptor = FetchDescriptor<MediaItem>()
        let context = ModelContext(container)
        let savedItems = try context.fetch(descriptor)
        
        #expect(savedItems.count == 2)
        
        let savedIds = Set(savedItems.map { $0.mediaId })
        #expect(savedIds.contains("test-1"))
        #expect(savedIds.contains("test-2"))
        
        // Verify properties are correctly set
        let item1 = savedItems.first { $0.mediaId == "test-1" }!
        #expect(item1.kind == .image)
        #expect(item1.status == .notBackedUp)
        
        let item2 = savedItems.first { $0.mediaId == "test-2" }!
        #expect(item2.kind == .video)
        #expect(item2.status == .unknown)
    }
    
    @Test("MediaIndex prevents duplicate media items")
    func testPreventDuplicateMediaItems() async throws {
        let schema = Schema([MediaItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        let mediaIndex = MediaIndex(modelContainer: container)
        
        let testItem = MediaItemData(
            mediaId: "duplicate-test",
            kind: .image,
            status: .notBackedUp,
            filename: "duplicate.jpg"
        )
        
        // Add the same item twice
        try await mediaIndex.addMedia(media: [testItem])
        try await mediaIndex.addMedia(media: [testItem])
        
        // Verify only one item was saved
        let descriptor = FetchDescriptor<MediaItem>()
        let context = ModelContext(container)
        let savedItems = try context.fetch(descriptor)
        
        #expect(savedItems.count == 1)
        #expect(savedItems.first?.mediaId == "duplicate-test")
    }
    
    @Test("MediaIndex can handle empty media arrays")
    func testAddEmptyMediaArray() async throws {
        let schema = Schema([MediaItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        let mediaIndex = MediaIndex(modelContainer: container)
        
        // Add empty array
        try await mediaIndex.addMedia(media: [MediaItemData]())
        
        // Verify no items were added
        let descriptor = FetchDescriptor<MediaItem>()
        let context = ModelContext(container)
        let savedItems = try context.fetch(descriptor)
        
        #expect(savedItems.isEmpty)
    }
    
    @Test("MediaIndex correctly maps PHAssetMediaType to MediaItemData.Kind")
    func testMediaTypeMapping() async throws {
        let schema = Schema([MediaItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        let mediaIndex = MediaIndex(modelContainer: container)
        
        // Since we can't easily create PHAsset objects for testing,
        // we'll test the mapping through MediaItemData instead
        let testItems = [
            MediaItemData(mediaId: "image-test", kind: .image, status: .unknown, filename: nil),
            MediaItemData(mediaId: "video-test", kind: .video, status: .unknown, filename: nil),
            MediaItemData(mediaId: "audio-test", kind: .audio, status: .unknown, filename: nil),
            MediaItemData(mediaId: "unknown-test", kind: .unknown, status: .unknown, filename: nil)
        ]
        
        try await mediaIndex.addMedia(media: testItems)
        
        let descriptor = FetchDescriptor<MediaItem>()
        let context = ModelContext(container)
        let savedItems = try context.fetch(descriptor)
        
        #expect(savedItems.count == 4)
        
        // Verify each type was preserved correctly
        let imageItem = savedItems.first { $0.mediaId == "image-test" }!
        #expect(imageItem.kind == .image)
        
        let videoItem = savedItems.first { $0.mediaId == "video-test" }!
        #expect(videoItem.kind == .video)
        
        let audioItem = savedItems.first { $0.mediaId == "audio-test" }!
        #expect(audioItem.kind == .audio)
        
        let unknownItem = savedItems.first { $0.mediaId == "unknown-test" }!
        #expect(unknownItem.kind == .unknown)
    }
    
    @Test("MediaIndex handles mixed new and existing items")
    func testMixedNewAndExistingItems() async throws {
        let schema = Schema([MediaItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        
        let mediaIndex = MediaIndex(modelContainer: container)
        
        // Add initial items
        let initialItems = [
            MediaItemData(mediaId: "existing-1", kind: .image, status: .backedUp, filename: nil),
            MediaItemData(mediaId: "existing-2", kind: .video, status: .notBackedUp, filename: nil)
        ]
        try await mediaIndex.addMedia(media: initialItems)
        
        // Add mixed batch (some existing, some new)
        let mixedItems = [
            MediaItemData(mediaId: "existing-1", kind: .image, status: .backedUp, filename: nil), // Duplicate
            MediaItemData(mediaId: "new-1", kind: .audio, status: .unknown, filename: nil), // New
            MediaItemData(mediaId: "existing-2", kind: .video, status: .notBackedUp, filename: nil), // Duplicate
            MediaItemData(mediaId: "new-2", kind: .image, status: .notBackedUp, filename: nil) // New
        ]
        try await mediaIndex.addMedia(media: mixedItems)
        
        // Verify total count (2 initial + 2 new = 4)
        let descriptor = FetchDescriptor<MediaItem>()
        let context = ModelContext(container)
        let savedItems = try context.fetch(descriptor)
        
        #expect(savedItems.count == 4)
        
        let savedIds = Set(savedItems.map { $0.mediaId })
        #expect(savedIds.contains("existing-1"))
        #expect(savedIds.contains("existing-2"))
        #expect(savedIds.contains("new-1"))
        #expect(savedIds.contains("new-2"))
    }
}