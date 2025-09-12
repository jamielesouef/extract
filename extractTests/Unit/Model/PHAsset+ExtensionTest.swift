//
//  PHAsset+ExtensionTest.swift
//  extractTests
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Foundation
import Photos
import Testing

@testable import extract

@Suite("PHAsset+Extension Tests")
struct PHAssetExtensionTests {
  @Test(
    "getCloudIdentifier generates correct identifier for photo with creation date"
  )
  @MainActor
  func cloudIdentifierForPhotoWithCreationDate() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01T00:00:00Z

    let mockAsset = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    #expect(mockAsset.id.contains("2021-01-01T00-00-00Z"))
    #expect(mockAsset.id.contains("photo"))
    #expect(mockAsset.id.contains("1920x1080"))
    #expect(mockAsset.id.contains("0.0"))
  }

  @Test(
    "getCloudIdentifier generates correct identifier for video with creation date"
  )
  @MainActor
  func cloudIdentifierForVideoWithCreationDate() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01T00:00:00Z

    let mockAsset = MockPHAsset(
      mediaType: .video,
      creationDate: testDate,
      pixelWidth: 3840,
      pixelHeight: 2160,
      duration: 30.5
    )

    #expect(mockAsset.id.contains("2021-01-01T00-00-00Z"))
    #expect(mockAsset.id.contains("video"))
    #expect(mockAsset.id.contains("3840x2160"))
    #expect(mockAsset.id.contains("30.5"))
  }

  @Test(
    "getCloudIdentifier falls back to localIdentifier when creation date is nil"
  )
  @MainActor
  func cloudIdentifierFallbackForNilCreationDate() async throws {
    let testLocalId = "test-fallback-id-12345"

    let mockAsset = MockPHAsset(
      localIdentifier: testLocalId,
      mediaType: .image,
      creationDate: nil
    )

    // Should use localIdentifier when creationDate is nil
    #expect(mockAsset.id.contains(testLocalId))
    #expect(mockAsset.id.contains("photo"))
    #expect(mockAsset.id.contains("1920x1080")) // Default dimensions from MockPHAsset
    #expect(mockAsset.id.contains("0.0")) // Default duration

    // Should be consistent for the same object
    let id1 = mockAsset.id
    let id2 = mockAsset.id
    #expect(id1 == id2)
  }

  @Test("getCloudIdentifier generates unique identifiers for different assets")
  @MainActor
  func cloudIdentifierUniqueness() async throws {
    let asset1 = MockPHAsset(
      mediaType: .image,
      creationDate: Date(timeIntervalSince1970: 1_609_459_200),
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    let asset2 = MockPHAsset(
      mediaType: .image,
      creationDate: Date(timeIntervalSince1970: 1_609_459_260),
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    let asset3 = MockPHAsset(
      mediaType: .video,
      creationDate: Date(timeIntervalSince1970: 1_609_459_200), // Different media type
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    // All should be different
    #expect(asset1.id != asset3.id)
    #expect(asset2.id != asset1.id)
    #expect(asset3.id != asset1.id)
  }

  @Test("getCloudIdentifier generates same identifier for identical assets")
  @MainActor
  func cloudIdentifierConsistency() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let asset1 = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    let asset2 = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    #expect(asset1.id == asset2.id)
  }

  @Test("getCloudIdentifier handles different asset dimensions")
  @MainActor
  func cloudIdentifierDifferentDimensions() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let smallAsset = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 640,
      pixelHeight: 480
    )

    let largeAsset = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 4096,
      pixelHeight: 3072
    )

    #expect(smallAsset.id != largeAsset.id)
    #expect(smallAsset.id.contains("640x480"))
    #expect(largeAsset.id.contains("4096x3072"))
  }

  @Test("getCloudIdentifier handles zero dimensions")
  @MainActor
  func cloudIdentifierZeroDimensions() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let zeroDimensionAsset = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 0,
      pixelHeight: 0,
      duration: 0.0
    )

    #expect(zeroDimensionAsset.id.contains("0x0"))
    #expect(zeroDimensionAsset.id.contains("photo"))
    #expect(zeroDimensionAsset.id.contains("0.0"))
  }

  @Test("getCloudIdentifier handles very long video duration")
  @MainActor
  func cloudIdentifierLongVideoDuration() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let longVideoAsset = MockPHAsset(
      mediaType: .video,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 3661.5 // 1 hour, 1 minute, 1.5 seconds
    )

    #expect(longVideoAsset.id.contains("video"))
    #expect(longVideoAsset.id.contains("3661.5"))
  }

  @Test("getCloudIdentifier handles fractional duration")
  @MainActor
  func cloudIdentifierFractionalDuration() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let fractionalAsset = MockPHAsset(
      mediaType: .video,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.123456789
    )

    #expect(fractionalAsset.id.contains("0.123456789"))
  }

  @Test("getCloudIdentifier replaces colons in ISO date format")
  @MainActor
  func cloudIdentifierReplacesColons() async throws {
    let testDate = Date(timeIntervalSince1970: 1_609_505_523) // Contains time with colons

    let mockAsset = MockPHAsset(
      mediaType: .image,
      creationDate: testDate,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    // Should not contain any colons (they should be replaced with hyphens)
    #expect(!mockAsset.id.contains(":"))
    // Should contain hyphens instead
    #expect(mockAsset.id.contains("-"))
  }

  @Test("getCloudIdentifier handles very old dates")
  @MainActor
  func cloudIdentifierVeryOldDates() async throws {
    let veryOldDate = Date(timeIntervalSince1970: 0) // Unix epoch: 1970-01-01T00:00:00Z

    let mockAsset = MockPHAsset(
      mediaType: .image,
      creationDate: veryOldDate,
      pixelWidth: 640,
      pixelHeight: 480
    )

    #expect(mockAsset.id.contains("1970-01-01T00-00-00Z"))
  }

  @Test("getCloudIdentifier handles future dates")
  @MainActor
  func cloudIdentifierFutureDates() async throws {
    let mediaStore = MediaStore()
    let futureDate = Date(timeIntervalSince1970: 2_000_000_000) // May 18, 2033

    let mockAsset = MockPHAsset(
      mediaType: .video,
      creationDate: futureDate,
      pixelWidth: 3840,
      pixelHeight: 2160,
      duration: 45.0
    )

    #expect(mockAsset.id.contains("2033-05-18"))
  }

  @Test("getCloudIdentifier handles unknown media type")
  @MainActor
  func cloudIdentifierUnknownMediaType() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let unknownAsset = MockPHAsset(
      mediaType: .unknown,
      creationDate: testDate, // PHAssetMediaType.unknown
      pixelWidth: 1920,
      pixelHeight: 1080,
      duration: 0.0
    )

    // Should default to "video" for non-image types
    #expect(unknownAsset.id.contains("video"))
  }

  @Test("getCloudIdentifier handles audio media type")
  @MainActor
  func cloudIdentifierAudioMediaType() async throws {
    let mediaStore = MediaStore()
    let testDate = Date(timeIntervalSince1970: 1_609_459_200)

    let audioAsset = MockPHAsset(
      mediaType: .audio,
      creationDate: testDate,
      pixelWidth: 0,
      pixelHeight: 0,
      duration: 180.5
    )

    #expect(audioAsset.id.contains("video")) // Audio treated as video in the logic
    #expect(audioAsset.id.contains("180.5"))
  }

  @Test("getCloudIdentifier handles empty localIdentifier and nil creation date")
  @MainActor
  func cloudIdentifierHandlesEmptyIdentifierAndNilDate() async throws {
    let mockAsset = MockPHAsset(
      localIdentifier: "", // Empty identifier
      mediaType: .image,
      creationDate: nil // Nil creation date
    )

    let id = mockAsset.id

    // Should generate deterministic ID based on object properties
    #expect(id.contains("unknown-"))
    #expect(id.contains("photo"))
    #expect(id.contains("1920x1080"))
    #expect(id.contains("0.0"))

    // Should be consistent for the same object
    let id2 = mockAsset.id
    #expect(id == id2)
  }
}
