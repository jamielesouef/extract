//
//  MediaItemTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

@testable import extract
import SwiftData
import Testing

@Suite("MediaItem Tests")
struct MediaItemTests {
  @Test("MediaItem initializes with correct values")
  func mediaItemInitialization() {
    let testID = "test-asset-id"
    let mediaItem = MediaItem(
      mediaId: testID,
      kind: MediaItemData.Kind.image,
      status: MediaItemData.Status.notBackedUp
    )

    #expect(mediaItem.mediaId == testID)
    #expect(mediaItem.kind == MediaItemData.Kind.image)
    #expect(mediaItem.status == MediaItemData.Status.notBackedUp)
    #expect(mediaItem.filename == nil)
  }

  @Test("MediaItem can be created with filename")
  func mediaItemWithFilename() {
    let testID = "test-asset-id"
    let testFilename = "test.jpg"
    let mediaItem = MediaItem(
      mediaId: testID,
      kind: MediaItemData.Kind.image,
      status: MediaItemData.Status.notBackedUp,
      filename: testFilename
    )

    #expect(mediaItem.mediaId == testID)
    #expect(mediaItem.kind == MediaItemData.Kind.image)
    #expect(mediaItem.status == MediaItemData.Status.notBackedUp)
    #expect(mediaItem.filename == testFilename)
  }
}
