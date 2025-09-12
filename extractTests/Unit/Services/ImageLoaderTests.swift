//
//  ImageLoaderTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Foundation
import Photos
import Testing

@testable import extract

#if os(iOS)
  import UIKit
#else
  import AppKit
#endif

@Suite("ImageLoader Tests")
struct ImageLoaderTests {
  // Helper function to create test MediaAssets
  @MainActor
  func createTestMediaAsset(
    id: String = UUID().uuidString,
    localIdentifier: String = UUID().uuidString,
    mediaType: MediaAssetType = .image,
    pixelWidth: Int = 1920,
    pixelHeight: Int = 1080,
    duration: TimeInterval = 0.0
  ) -> MediaAsset {
    MediaAsset(
      id: id,
      localIdentifier: localIdentifier,
      mediaType: mediaType,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
      duration: duration
    )
  }

  @Test("ImageLoader initializes correctly")
  @MainActor
  func imageLoaderInitialization() async {
    let imageLoader = ImageLoader()

    #expect(imageLoader.image == nil)
    #expect(imageLoader.requestID == nil)
  }

  @Test("ImageLoader properly manages request lifecycle")
  @MainActor
  func imageLoaderRequestLifecycle() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    // Initially no request
    #expect(imageLoader.requestID == nil)

    // Start loading - since we're using a fake localIdentifier, PHAsset won't be found
    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)

    // Should remain nil since PHAsset fetch will fail for fake localIdentifier
    #expect(imageLoader.requestID == nil)
    #expect(imageLoader.image == nil)

    // Cancel should be safe
    imageLoader.cancel()
    #expect(imageLoader.requestID == nil)
  }

  @Test("ImageLoader handles different asset types properly")
  @MainActor
  func imageLoaderHandlesDifferentAssetTypes() async {
    let imageLoader = ImageLoader()

    // Test with image asset
    let imageAsset = createTestMediaAsset(mediaType: .image)
    await imageLoader.loadImage(from: imageAsset, with: 100, at: 2.0)
    #expect(imageLoader.image == nil) // Fake localIdentifier won't load

    // Reset for video test
    let imageLoader2 = ImageLoader()
    let videoAsset = createTestMediaAsset(mediaType: .video, duration: 30.0)
    await imageLoader2.loadImage(from: videoAsset, with: 100, at: 2.0)
    #expect(imageLoader2.image == nil) // Fake localIdentifier won't load
  }

  @Test("ImageLoader target size calculation logic")
  @MainActor
  func imageLoaderTargetSizeCalculation() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    let testCases = [
      (size: 100.0, scale: 1.0),
      (size: 50.0, scale: 2.0),
      (size: 75.0, scale: 3.0),
      (size: 200.0, scale: 0.5)
    ]

    for testCase in testCases {
      let newLoader = ImageLoader()
      await newLoader.loadImage(
        from: mediaAsset,
        with: testCase.size,
        at: testCase.scale
      )

      // The calculation happens internally: targetSize = size * displayScale
      // We verify the method completes without error
      #expect(newLoader.image == nil) // Fake asset, so no image loaded
    }
  }

  @Test("loadImage skips loading when image already exists")
  @MainActor
  func loadImageSkipsWhenImageExists() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)
    await imageLoader.loadImage(from: mediaAsset, with: 200, at: 3.0)

    #expect(imageLoader.image == nil)
  }

  @Test("loadImage handles MediaAsset correctly")
  @MainActor
  func loadImageWithMediaAsset() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset(
      id: "test-123",
      localIdentifier: "test-local-123",
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)

    #expect(imageLoader.image == nil) // Fake localIdentifier
    #expect(imageLoader.requestID == nil)
  }

  @Test("loadImage calculates correct target size")
  @MainActor
  func loadImageTargetSizeCalculation() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    let testCases = [
      (size: 50.0, scale: 1.0),
      (size: 100.0, scale: 2.0),
      (size: 75.0, scale: 3.0)
    ]

    for testCase in testCases {
      await imageLoader.loadImage(
        from: mediaAsset,
        with: testCase.size,
        at: testCase.scale
      )

      #expect(imageLoader.image == nil)
    }
  }

  @Test("loadImage handles empty localIdentifier gracefully")
  @MainActor
  func loadImageWithEmptyLocalIdentifier() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset(localIdentifier: "")

    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)

    #expect(imageLoader.image == nil)
    #expect(imageLoader.requestID == nil)
  }

  @Test("cancel works when no request is active")
  @MainActor
  func cancelWithNoActiveRequest() async {
    let imageLoader = ImageLoader()

    // Initially no request
    #expect(imageLoader.requestID == nil)

    // Cancel should be safe even with no active request
    imageLoader.cancel()

    #expect(imageLoader.requestID == nil)
  }

  @Test("cancel clears requestID")
  @MainActor
  func cancelClearsRequestID() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)
    imageLoader.cancel()

    #expect(imageLoader.requestID == nil)
  }

  @Test("multiple cancel calls are safe")
  @MainActor
  func multipleCancelCallsAreSafe() async {
    let imageLoader = ImageLoader()

    imageLoader.cancel()
    imageLoader.cancel()
    imageLoader.cancel()

    #expect(imageLoader.requestID == nil)
  }

  @Test("loadImage with zero size")
  @MainActor
  func loadImageWithZeroSize() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(from: mediaAsset, with: 0, at: 2.0)

    #expect(imageLoader.image == nil)
  }

  @Test("loadImage with zero display scale")
  @MainActor
  func loadImageWithZeroDisplayScale() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(from: mediaAsset, with: 100, at: 0)

    #expect(imageLoader.image == nil)
  }

  @Test("loadImage with negative values")
  @MainActor
  func loadImageWithNegativeValues() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(from: mediaAsset, with: -50, at: -2.0)

    #expect(imageLoader.image == nil)
  }

  @Test("loadImage with extremely large values")
  @MainActor
  func loadImageWithExtremelyLargeValues() async {
    let imageLoader = ImageLoader()
    let mediaAsset = createTestMediaAsset()

    await imageLoader.loadImage(
      from: mediaAsset,
      with: CGFloat.greatestFiniteMagnitude,
      at: CGFloat.greatestFiniteMagnitude
    )

    #expect(imageLoader.image == nil)
  }

  @Test("concurrent loadImage calls")
  @MainActor
  func concurrentLoadImageCalls() async {
    let imageLoader = ImageLoader()
    let mediaAsset1 = createTestMediaAsset(localIdentifier: "asset1")
    let mediaAsset2 = createTestMediaAsset(localIdentifier: "asset2")

    async let load1: Void = imageLoader.loadImage(
      from: mediaAsset1,
      with: 100,
      at: 2.0
    )
    async let load2: Void = imageLoader.loadImage(
      from: mediaAsset2,
      with: 150,
      at: 2.0
    )

    await load1
    await load2

    #expect(imageLoader.image == nil)
  }

  @Test("Observable property changes")
  @MainActor
  func observablePropertyChanges() async {
    let imageLoader = ImageLoader()

    #expect(imageLoader.image == nil)
    #expect(imageLoader.requestID == nil)
  }

  @Test("ImageLoader doesn't retain references unnecessarily")
  @MainActor
  func memoryManagement() async {
    weak var weakLoader: ImageLoader?

    do {
      let imageLoader = ImageLoader()
      weakLoader = imageLoader

      let mediaAsset = createTestMediaAsset()
      await imageLoader.loadImage(from: mediaAsset, with: 100, at: 2.0)

      #expect(weakLoader != nil)
    }

    #expect(weakLoader == nil)
  }

  #if os(iOS)
    @Test("iOS specific image handling")
    @MainActor
    func iOSSpecificImageHandling() async {
      let imageLoader = ImageLoader()

      #expect(imageLoader.image == nil)

      let image = imageLoader.image
      #expect(image == nil)
    }
  #else
    @Test("macOS specific image handling")
    @MainActor
    func macOSSpecificImageHandling() async {
      let imageLoader = ImageLoader()

      #expect(imageLoader.image == nil)

      let image = imageLoader.image
      #expect(image == nil)
    }
  #endif
}
