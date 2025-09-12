//
//  MediaAssetTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Foundation
import Photos
import Testing

@testable import extract

@Suite("MediaAsset Tests")
@MainActor
struct MediaAssetTests {
  @Test("MediaAsset initializes correctly from test data")
  func mediaAssetInitialization() {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01T00:00:00Z

    let mediaAsset = MediaAsset(
      id: "test-id",
      localIdentifier: "test-local-id",
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    #expect(mediaAsset.id == "test-id")
    #expect(mediaAsset.localIdentifier == "test-local-id")
    #expect(mediaAsset.mediaType == .image)
    #expect(mediaAsset.creationDate == testDate)
    #expect(mediaAsset.pixelWidth == 1920)
    #expect(mediaAsset.pixelHeight == 1080)
    #expect(mediaAsset.duration == 0.0)

    // Test computed properties
    #expect(mediaAsset.isImage == true)
    #expect(mediaAsset.isVideo == false)
    #expect(mediaAsset.aspectRatio == 1920.0 / 1080.0)
  }

  @Test("MediaAsset handles video correctly")
  func mediaAssetVideoHandling() {
    let mediaAsset = MediaAsset(
      mediaType: .video,
      pixelWidth: 3840,
      pixelHeight: 2160,
      duration: 30.5
    )

    #expect(mediaAsset.mediaType == .video)
    #expect(mediaAsset.isImage == false)
    #expect(mediaAsset.isVideo == true)
    #expect(mediaAsset.duration == 30.5)
    #expect(mediaAsset.aspectRatio == 3840.0 / 2160.0)
  }

  @Test("MediaAsset handles zero height gracefully")
  func mediaAssetZeroHeight() {
    let mediaAsset = MediaAsset(
      pixelWidth: 1920,
      pixelHeight: 0
    )

    #expect(mediaAsset.aspectRatio == 1.0) // Should default to 1.0
  }

  @Test("MediaAsset conforms to Identifiable")
  func mediaAssetIdentifiable() {
    let mediaAsset1 = MediaAsset(id: "id1")
    let mediaAsset2 = MediaAsset(id: "id2")

    #expect(mediaAsset1.id == "id1")
    #expect(mediaAsset2.id == "id2")
    #expect(mediaAsset1.id != mediaAsset2.id)
  }

  @Test("MediaAsset conforms to Hashable")
  func mediaAssetHashable() {
    let mediaAsset1 = MediaAsset(id: "same-id", localIdentifier: "local-1")
    let mediaAsset2 = MediaAsset(id: "same-id", localIdentifier: "local-2")
    let mediaAsset3 = MediaAsset(id: "different-id", localIdentifier: "local-3")

    #expect(mediaAsset1 == mediaAsset2) // Same ID means equal
    #expect(mediaAsset1 != mediaAsset3) // Different ID means not equal

    let set: Set<MediaAsset> = [mediaAsset1, mediaAsset2, mediaAsset3]
    #expect(set.count == 2) // mediaAsset1 and mediaAsset2 should be deduplicated by ID
  }

  @Test("MediaAssetType conversion from PHAssetMediaType")
  func mediaAssetTypeConversion() {
    #expect(MediaAssetType(from: .image) == .image)
    #expect(MediaAssetType(from: .video) == .video)
    #expect(MediaAssetType(from: .audio) == .audio)
    #expect(MediaAssetType(from: .unknown) == .unknown)
  }

  @Test("Array extensions work correctly")
  func arrayExtensions() {
    let assets = [
      MediaAsset(mediaType: .image),
      MediaAsset(mediaType: .video),
      MediaAsset(mediaType: .image),
      MediaAsset(mediaType: .audio)
    ]

    #expect(assets.imageCount == 2)
    #expect(assets.videoCount == 1)
  }
}
