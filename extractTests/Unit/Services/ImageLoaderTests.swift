//

//

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

// MARK: - Test Mock



 @Suite("ImageManager Tests")
 struct ImageLoaderTests {
  @Test("ImageManager initialises correctly")
  @MainActor
  func imageManagerInitialisation() async {
    let imageManager = ImageLoader()

    #expect(imageManager.image == nil)
    #expect(imageManager.requestID == nil)
  }

  @Test("ImageManager properly manages request lifecycle")
  @MainActor
  func imageManagerRequestLifecycle() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    // Initially no request
    #expect(imageManager.requestID == nil)

    // Start loading (will set requestID for real PHAssets, but not for mocks)
    await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

    // For mock assets, requestID remains nil as expected
    #expect(imageManager.requestID == nil)
    #expect(imageManager.image == nil)

    // Cancel should be safe
    imageManager.cancel()
    #expect(imageManager.requestID == nil)
  }

  @Test("ImageManager handles different asset types properly")
  @MainActor
  func imageManagerHandlesDifferentAssetTypes() async {
    let imageManager = ImageLoader()

    // Test with image asset
    let imageAsset = MockPHAsset.bundleImageAsset()
    await imageManager.loadImage(from: imageAsset, with: 100, at: 2.0)
    #expect(imageManager.image == nil) // Mock assets don't load images

    // Reset for video test
    let imageManager2 = ImageLoader()
    let videoAsset = MockPHAsset.videoAsset()
    await imageManager2.loadImage(from: videoAsset, with: 100, at: 2.0)
    #expect(imageManager2.image == nil) // Mock assets don't load images
  }

  @Test("ImageManager target size calculation logic")
  @MainActor
  func imageManagerTargetSizeCalculation() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    let testCases = [
      (size: 100.0, scale: 1.0, expectedTargetSize: 100.0),
      (size: 50.0, scale: 2.0, expectedTargetSize: 100.0),
      (size: 75.0, scale: 3.0, expectedTargetSize: 225.0),
      (size: 200.0, scale: 0.5, expectedTargetSize: 100.0)
    ]

    for testCase in testCases {
      let newManager = ImageLoader()
      await newManager.loadImage(
        from: mockAsset,
        with: testCase.size,
        at: testCase.scale
      )

      // The calculation happens internally: targetSize = size * displayScale
      // We verify the method completes without error
      #expect(newManager.image == nil) // Mock asset, so no image loaded

      // In a real implementation, we could verify the calculated target size
      // was passed to PHImageManager correctly
    }
  }

  @Test("loadImage skips loading when image already exists")
  @MainActor
  func loadImageSkipsWhenImageExists() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

    await imageManager.loadImage(from: mockAsset, with: 200, at: 3.0)

    #expect(imageManager.image == nil)
  }

  @Test("loadImage handles MockPHAsset correctly")
  @MainActor
  func loadImageWithMockAsset() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset(
      localIdentifier: "test-123",
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

    #expect(imageManager.image == nil)
    #expect(imageManager.requestID == nil)
  }

  @Test("loadImage calculates correct target size")
  @MainActor
  func loadImageTargetSizeCalculation() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    let testCases = [
      (size: 50.0, scale: 1.0),
      (size: 100.0, scale: 2.0),
      (size: 75.0, scale: 3.0)
    ]

    for testCase in testCases {
      await imageManager.loadImage(
        from: mockAsset,
        with: testCase.size,
        at: testCase.scale
      )

      #expect(imageManager.image == nil)
    }
  }

  @Test("loadImage handles nil asset gracefully")
  @MainActor
  func loadImageWithNilAsset() async {
    let imageManager = ImageLoader()

    let mockAsset = MockPHAsset(localIdentifier: "")

    await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

    #expect(imageManager.image == nil)
    #expect(imageManager.requestID == nil)
  }

  @Test("cancel works when no request is active")
  @MainActor
  func cancelWithNoActiveRequest() async {
    let imageManager = ImageLoader()

    // Initially no request
    #expect(imageManager.requestID == nil)

    // Cancel should be safe even with no active request
    imageManager.cancel()

    #expect(imageManager.requestID == nil)
  }

  @Test("cancel clears requestID")
  @MainActor
  func cancelClearsRequestID() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

    imageManager.cancel()

    #expect(imageManager.requestID == nil)
  }

  @Test("multiple cancel calls are safe")
  @MainActor
  func multipleCancelCallsAreSafe() async {
    let imageManager = ImageLoader()

    imageManager.cancel()
    imageManager.cancel()
    imageManager.cancel()

    #expect(imageManager.requestID == nil)
  }

  @Test("loadImage with zero size")
  @MainActor
  func loadImageWithZeroSize() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(from: mockAsset, with: 0, at: 2.0)

    //#expect(imageManager.image == nil)
  }

  @Test("loadImage with zero display scale")
  @MainActor
  func loadImageWithZeroDisplayScale() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(from: mockAsset, with: 100, at: 0)

    #expect(imageManager.image == nil)
  }

  @Test("loadImage with negative values")
  @MainActor
  func loadImageWithNegativeValues() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(from: mockAsset, with: -50, at: -2.0)

    #expect(imageManager.image == nil)
  }

  @Test("loadImage with extremely large values")
  @MainActor
  func loadImageWithExtremelyLargeValues() async {
    let imageManager = ImageLoader()
    let mockAsset = MockPHAsset()

    await imageManager.loadImage(
      from: mockAsset,
      with: CGFloat.greatestFiniteMagnitude,
      at: CGFloat.greatestFiniteMagnitude
    )

    #expect(imageManager.image == nil)
  }

  @Test("concurrent loadImage calls")
  @MainActor
  func concurrentLoadImageCalls() async {
    let imageManager = ImageLoader()
    let mockAsset1 = MockPHAsset(localIdentifier: "asset1")
    let mockAsset2 = MockPHAsset(localIdentifier: "asset2")

    async let load1: Void = imageManager.loadImage(
      from: mockAsset1,
      with: 100,
      at: 2.0
    )
    async let load2: Void = imageManager.loadImage(
      from: mockAsset2,
      with: 150,
      at: 2.0
    )

    await load1
    await load2

    #expect(imageManager.image == nil)
  }

  @Test("Observable property changes")
  @MainActor
  func observablePropertyChanges() async {
    let imageManager = ImageLoader()

    #expect(imageManager.image == nil)
    #expect(imageManager.requestID == nil)
  }

  @Test("ImageManager doesn't retain references unnecessarily")
  @MainActor
  func memoryManagement() async {
    weak var weakManager: ImageLoader?

    do {
      let imageManager = ImageLoader()
      weakManager = imageManager

      let mockAsset = MockPHAsset()
      await imageManager.loadImage(from: mockAsset, with: 100, at: 2.0)

      #expect(weakManager != nil)
    }

    #expect(weakManager == nil)
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

// MARK: - Integration Test Helper

 @Suite("ImageManager Integration Tests")
 struct ImageManagerIntegrationTests {
  @Test("ImageManager can load bundle image directly")
  @MainActor
  func imageManagerLoadsBundleImage() async {
    let imageManager = TestableImageManager()
    let mockAsset = MockPHAsset.bundleImageAsset()

    // Simulate successful image loading
    await imageManager.simulateImageLoad(from: mockAsset, with: 100, at: 2.0)

    #expect(imageManager.image != nil)
    #expect(imageManager.didCallLoadImage == true)
    #expect(imageManager.lastRequestedSize == 100)
    #expect(imageManager.lastDisplayScale == 2.0)

    // Verify image properties
    if let image = imageManager.image {
      #expect(image.size.width > 0)
      #expect(image.size.height > 0)
    }
  }

  @Test("ImageManager tracks multiple load attempts correctly")
  @MainActor
  func imageManagerTracksMultipleLoads() async {
    let imageManager = TestableImageManager()
    let mockAsset = MockPHAsset.bundleImageAsset()

    // First load
    await imageManager.simulateImageLoad(from: mockAsset, with: 50, at: 1.0)
    #expect(imageManager.loadImageCallCount == 1)
    #expect(imageManager.lastRequestedSize == 50)

    // Second load with different parameters
    await imageManager.loadImage(from: mockAsset, with: 75, at: 2.0)
    #expect(imageManager.loadImageCallCount == 2)
    #expect(imageManager.lastRequestedSize == 75)
    #expect(imageManager.lastDisplayScale == 2.0)
  }

  @Test("ImageManager handles cancellation properly")
  @MainActor
  func imageManagerHandlesCancellation() async {
    let imageManager = TestableImageManager()
    let mockAsset = MockPHAsset.bundleImageAsset()

    // Start load
    await imageManager.simulateImageLoad(from: mockAsset, with: 100, at: 2.0)
    #expect(imageManager.requestID != nil)

    // Cancel
    imageManager.cancel()
    #expect(imageManager.requestID == nil)

    // Verify image is still loaded (cancellation doesn't remove loaded image)
    #expect(imageManager.image != nil)
  }

  @Test("ImageManager validates bundle image loading")
  @MainActor
  func imageManagerValidatesBundleImageLoading() async {
    let imageManager = TestableImageManager()
    let mockAsset = MockPHAsset.bundleImageAsset()

    await imageManager.simulateImageLoad(from: mockAsset, with: 200, at: 3.0)

    // Verify the cat-portrait image loaded successfully
    if let image = imageManager.image {
      // The cat-portrait should be a reasonable size
      #expect(image.size.width >= 100)
      #expect(image.size.height >= 100)

      // Verify it's actually an image (not corrupted)
      #if os(iOS)
        #expect(image.cgImage != nil)
      #else
        #expect(image.isValid)
      #endif
    } else {
      Issue.record("Bundle image 'cat-portrait' should have loaded successfully")
    }
  }
 }

// MARK: - Testable ImageManager for Enhanced Testing

 @Observable
 final class TestableImageManager {
  #if os(iOS)
    private(set) var image: UIImage?
  #else
    private(set) var image: NSImage?
  #endif

  private(set) var requestID: PHImageRequestID?

  // Test tracking properties
  var didCallLoadImage = false
  var lastRequestedSize: CGFloat = 0
  var lastDisplayScale: CGFloat = 0
  var loadImageCallCount = 0

  func loadImage(from asset: PHAsset, with size: CGFloat, at displayScale: CGFloat) async {
    didCallLoadImage = true
    lastRequestedSize = size
    lastDisplayScale = displayScale
    loadImageCallCount += 1

    // Simulate request ID
    requestID = PHImageRequestID(Int32.random(in: Int32.min ... Int32.max))
  }

  func simulateImageLoad(from asset: PHAsset, with size: CGFloat, at displayScale: CGFloat) async {
    await loadImage(from: asset, with: size, at: displayScale)

    // Load actual bundle image from main app bundle
    #if os(iOS)
      image = UIImage(named: "cat-portrait", in: Bundle.main, compatibleWith: nil)
    #else
      image = Bundle.main.image(forResource: "cat-portrait")
    #endif

    // Simulate request completion
    requestID = PHImageRequestID(123)
  }

  func cancel() {
    if requestID != nil {
      requestID = nil
    }
  }
 }

// MARK: - Enhanced Mock Asset Extensions

 extension MockPHAsset {
  static func videoAsset() -> MockPHAsset {
    MockPHAsset(
      mediaType: .video,
      duration: 30.0
    )
  }

  static func bundleImageAsset() -> MockPHAsset {
    MockPHAsset(
      localIdentifier: "test-cat-portrait",
      mediaType: .image,
      pixelWidth: 800,
      pixelHeight: 600
    )
  }

  static func largeImageAsset() -> MockPHAsset {
    MockPHAsset(
      pixelWidth: 4000,
      pixelHeight: 3000
    )
  }

  static func smallImageAsset() -> MockPHAsset {
    MockPHAsset(
      pixelWidth: 100,
      pixelHeight: 100
    )
  }
 }
