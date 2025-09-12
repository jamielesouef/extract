//
//  MediaStoreTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

@testable import extract
import Foundation
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

// MARK: - Cloud Identifier Tests

@Suite("MediaStore Cloud Identifier Tests")
struct MediaStoreCloudIdentifierTests {
  // Mock PHAsset class for testing
  class MockPHAsset: PHAsset, @unchecked Sendable {
    private let _creationDate: Date?
    private let _mediaType: PHAssetMediaType
    private let _pixelWidth: Int
    private let _pixelHeight: Int
    private let _duration: TimeInterval
    private let _localIdentifier: String

    init(creationDate: Date?,
         mediaType: PHAssetMediaType,
         pixelWidth: Int = 1920,
         pixelHeight: Int = 1080,
         duration: TimeInterval = 0.0,
         localIdentifier: String = "test-local-id")
    {
      _creationDate = creationDate
      _mediaType = mediaType
      _pixelWidth = pixelWidth
      _pixelHeight = pixelHeight
      _duration = duration
      _localIdentifier = localIdentifier
      super.init()
    }

    override var creationDate: Date? { _creationDate }
    override var mediaType: PHAssetMediaType { _mediaType }
    override var pixelWidth: Int { _pixelWidth }
    override var pixelHeight: Int { _pixelHeight }
    override var duration: TimeInterval { _duration }
    override var localIdentifier: String { _localIdentifier }
  }

  @Test("createSelectionContainer handles creating a new storage object")
  @MainActor
  func createSelectionContainer() async throws {
    let mediaStore = MediaStore()

    #expect(mediaStore.selectionContainer == nil)
    mediaStore.createSelectionContainer()
    #expect(mediaStore.selectionContainer != nil)
    #expect(mediaStore.selectionContainer?.selected.count == 0)
  }

  @Test("resetSelectionContainer handles sets the storage object to nil")
  @MainActor
  func resetSelectionContainer() async throws {
    let mediaStore = MediaStore()
    mediaStore.createSelectionContainer()

    #expect(mediaStore.selectionContainer != nil)
    mediaStore.resetSelectionContainer()

    #expect(mediaStore.selectionContainer == nil)
  }
}
