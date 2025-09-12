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
@MainActor
struct MediaStoreTests {
  @Test("MediaStore initializes correctly")
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
  func countProperty() async {
    let mediaStore = MediaStore()

    // Initially empty
    #expect(mediaStore.count == 0)

    // Test with MediaAssets
    let testAssets = [
      MediaAsset(mediaType: .image),
      MediaAsset(mediaType: .video),
      MediaAsset(mediaType: .image)
    ]

    let mediaStoreWithItems = MediaStore(items: testAssets)
    #expect(mediaStoreWithItems.count == 3)
  }

  @Test("MediaStore handles MediaAssets correctly")
  func mediaStoreWithMediaAssets() async {
    let testAssets = [
      MediaAsset(id: "image1", mediaType: .image, pixelWidth: 1920, pixelHeight: 1080),
      MediaAsset(id: "video1", mediaType: .video, duration: 30.5),
      MediaAsset(id: "image2", mediaType: .image, pixelWidth: 3840, pixelHeight: 2160)
    ]

    let mediaStore = MediaStore(items: testAssets)

    #expect(mediaStore.items.count == 3)
    #expect(mediaStore.count == 3)

    // Check that items maintain their properties
    let firstItem = mediaStore.items[0]
    #expect(firstItem.id == "image1")
    #expect(firstItem.isImage == true)
    #expect(firstItem.aspectRatio == 1920.0 / 1080.0)

    let videoItem = mediaStore.items[1]
    #expect(videoItem.id == "video1")
    #expect(videoItem.isVideo == true)
    #expect(videoItem.duration == 30.5)
  }

  @Test("createSelectionContainer handles creating a new storage object")
  func createSelectionContainer() async throws {
    let mediaStore = MediaStore()

    #expect(mediaStore.selectionContainer == nil)
    mediaStore.createSelectionContainer()
    #expect(mediaStore.selectionContainer != nil)
    #expect(mediaStore.selectionContainer?.selected.count == 0)
  }

  @Test("resetSelectionContainer handles sets the storage object to nil")
  func resetSelectionContainer() async throws {
    let mediaStore = MediaStore()
    mediaStore.createSelectionContainer()

    #expect(mediaStore.selectionContainer != nil)
    mediaStore.resetSelectionContainer()

    #expect(mediaStore.selectionContainer == nil)
  }

  @Test("SelectionContainer works with MediaAssets")
  func selectionContainerWithMediaAssets() async throws {
    let mediaStore = MediaStore()
    let testAsset = MediaAsset(id: "test-asset", mediaType: .image)

    mediaStore.createSelectionContainer()
    mediaStore.selectionContainer?.select(testAsset)

    #expect(mediaStore.selectionContainer?.selected.count == 1)
    #expect(mediaStore.selectionContainer?.selected.contains(testAsset) == true)
  }
}
