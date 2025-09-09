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
  class MockPHAsset: PHAsset {
    private let _creationDate: Date?
    private let _mediaType: PHAssetMediaType
    private let _pixelWidth: Int
    private let _pixelHeight: Int
    private let _duration: TimeInterval
    private let _localIdentifier: String

    init(
      creationDate: Date?,
      mediaType: PHAssetMediaType,
      pixelWidth: Int = 1920,
      pixelHeight: Int = 1080,
      duration: TimeInterval = 0.0,
      localIdentifier: String = "test-local-id"
    ) {
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

  @Test("getCloudIdentifier generates correct identifier for photo with creation date")
  @MainActor
  func cloudIdentifierForPhotoWithCreationDate() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01T00:00:00Z

    let mockAsset = MockPHAsset(
      creationDate: testDate,
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    let identifier = await mediaStore.getCloudIdentifier(for: mockAsset)

    #expect(identifier != nil)
    #expect(identifier!.contains("2021-01-01T00-00-00Z"))
    #expect(identifier!.contains("photo"))
    #expect(identifier!.contains("1920x1080"))
    #expect(identifier!.contains("0.0"))
  }

  @Test("getCloudIdentifier generates correct identifier for video with creation date")
  @MainActor
  func cloudIdentifierForVideoWithCreationDate() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01T00:00:00Z

    let mockAsset = MockPHAsset(
      creationDate: testDate,
      mediaType: .video,
      pixelWidth: 3840,
      pixelHeight: 2160,
      duration: 30.5
    )

    let identifier = await mediaStore.getCloudIdentifier(for: mockAsset)

    #expect(identifier != nil)
    #expect(identifier!.contains("2021-01-01T00-00-00Z"))
    #expect(identifier!.contains("video"))
    #expect(identifier!.contains("3840x2160"))
    #expect(identifier!.contains("30.5"))
  }

  @Test("getCloudIdentifier falls back to localIdentifier when creation date is nil")
  @MainActor
  func cloudIdentifierFallbackForNilCreationDate() async throws {
    let mediaStore = MediaStore()
    let testLocalId = "test-fallback-id-12345"

    let mockAsset = MockPHAsset(
      creationDate: nil,
      mediaType: .image,
      localIdentifier: testLocalId
    )

    let identifier = await mediaStore.getCloudIdentifier(for: mockAsset)

    #expect(identifier == testLocalId)
  }

  @Test("getCloudIdentifier generates unique identifiers for different assets")
  @MainActor
  func cloudIdentifierUniqueness() async throws {
    let mediaStore = MediaStore()

    let asset1 = MockPHAsset(
      creationDate: Date(timeIntervalSince1970: 1_609_459_200),
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    let asset2 = MockPHAsset(
      creationDate: Date(timeIntervalSince1970: 1_609_459_260), // 1 minute later
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    let asset3 = MockPHAsset(
      creationDate: Date(timeIntervalSince1970: 1_609_459_200), // Same time as asset1
      mediaType: .video, // Different media type
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    let id1 = await mediaStore.getCloudIdentifier(for: asset1)
    let id2 = await mediaStore.getCloudIdentifier(for: asset2)
    let id3 = await mediaStore.getCloudIdentifier(for: asset3)

    // All should be different
    #expect(id1 != id2)
    #expect(id1 != id3)
    #expect(id2 != id3)
  }

  @Test("getCloudIdentifier generates same identifier for identical assets")
  @MainActor
  func cloudIdentifierConsistency() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let asset1 = MockPHAsset(
      creationDate: testDate,
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    let asset2 = MockPHAsset(
      creationDate: testDate,
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    let id1 = await mediaStore.getCloudIdentifier(for: asset1)
    let id2 = await mediaStore.getCloudIdentifier(for: asset2)

    #expect(id1 == id2)
  }

  @Test("getCloudIdentifier handles different asset dimensions")
  @MainActor
  func cloudIdentifierDifferentDimensions() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let smallAsset = MockPHAsset(
      creationDate: testDate,
      mediaType: .image,
      pixelWidth: 640,
      pixelHeight: 480
    )

    let largeAsset = MockPHAsset(
      creationDate: testDate,
      mediaType: .image,
      pixelWidth: 4096,
      pixelHeight: 3072
    )

    let smallId = await mediaStore.getCloudIdentifier(for: smallAsset)
    let largeId = await mediaStore.getCloudIdentifier(for: largeAsset)

    #expect(smallId != largeId)
    #expect(smallId!.contains("640x480"))
    #expect(largeId!.contains("4096x3072"))
  }
}
