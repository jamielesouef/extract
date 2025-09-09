//
//  MediaStoreTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

@testable import extract
import Photos
import Testing

@Suite("MediaStore Tests")
struct MediaStoreTests {
  @Test("MediaStore initializes correctly")
  @MainActor
  func mediaStoreInitialization() async {
    let mediaStore = MediaStore()

    #expect(mediaStore.items.isEmpty)
    #expect(mediaStore.authorizationStatus == nil)
    #expect(mediaStore.isLoading == false)
    #expect(mediaStore.count == 0)
    #expect(mediaStore.photosCount == 0)
    #expect(mediaStore.videoCount == 0)
  }

  @Test("Count property returns correct value")
  @MainActor
  func countProperty() async {
    let mediaStore = MediaStore()

    // Initially empty
    #expect(mediaStore.count == 0)

    // This test would need mock PHAssets to test with actual items
    // For now, we're testing the computed property works correctly
  }
}
