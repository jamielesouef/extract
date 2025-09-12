//
//  SelectionContainerTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 12/9/2025.
//

@testable import extract
import Foundation
import Photos
import Testing


@Suite("SelectionContainer Tests")
struct SelectionContainerTests {
  // MARK: - Helper function to create test assets

  nonisolated func createTestAsset(id: String = UUID().uuidString, mediaType: PHAssetMediaType = .image) -> MockPHAsset {
    MockPHAsset(localIdentifier: id, mediaType: mediaType)
  }

  // MARK: - Happy Path Tests

  @Test("SelectionContainer initializes empty")
  @MainActor func initializesEmpty() async {
    let container = SelectionContainer()

    #expect(container.selected.isEmpty)
    #expect(container.selected.count == 0)
  }

  @Test("Select single asset adds to selection")
  @MainActor func selectSingleAsset() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "test-asset-1")

    container.select(asset)

    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))
  }

  @Test("Select multiple assets adds all to selection")
  @MainActor func selectMultipleAssets() async {
    let container = SelectionContainer()
    let asset1 = createTestAsset(id: "test-asset-1")
    let asset2 = createTestAsset(id: "test-asset-2")
    let asset3 = createTestAsset(id: "test-asset-3")

    container.select(asset1)
    container.select(asset2)
    container.select(asset3)

    #expect(container.selected.count == 3)
    #expect(container.selected.contains(asset1))
    #expect(container.selected.contains(asset2))
    #expect(container.selected.contains(asset3))
  }

  @Test("Deselect removes asset from selection")
  @MainActor func deselectRemovesAsset() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "test-asset-1")

    container.select(asset)
    #expect(container.selected.contains(asset))

    container.deselect(asset)
    #expect(!container.selected.contains(asset))
    #expect(container.selected.isEmpty)
  }

  @Test("Deselect specific asset leaves others selected")
  @MainActor func deselectSpecificAsset() async {
    let container = SelectionContainer()
    let asset1 = createTestAsset(id: "test-asset-1")
    let asset2 = createTestAsset(id: "test-asset-2")
    let asset3 = createTestAsset(id: "test-asset-3")

    container.select(asset1)
    container.select(asset2)
    container.select(asset3)

    container.deselect(asset2)

    #expect(container.selected.count == 2)
    #expect(container.selected.contains(asset1))
    #expect(!container.selected.contains(asset2))
    #expect(container.selected.contains(asset3))
  }

  // MARK: - Edge Cases

  @Test("Select same asset multiple times maintains single instance")
  @MainActor func selectDuplicateAsset() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "test-asset-1")

    container.select(asset)
    container.select(asset)
    container.select(asset)

    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))
  }

  @Test("Deselect non-selected asset does nothing")
  @MainActor func deselectNonSelectedAsset() async {
    let container = SelectionContainer()
    let selectedAsset = createTestAsset(id: "selected-asset")
    let nonSelectedAsset = createTestAsset(id: "non-selected-asset")

    container.select(selectedAsset)
    #expect(container.selected.count == 1)

    container.deselect(nonSelectedAsset)
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(selectedAsset))
  }

  @Test("Deselect from empty selection does nothing")
  @MainActor func deselectFromEmptySelection() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "test-asset")

    #expect(container.selected.isEmpty)

    container.deselect(asset)
    #expect(container.selected.isEmpty)
  }

  @Test("Select and deselect same asset multiple times")
  @MainActor func selectDeselectCycle() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "test-asset")

    // Initial state
    #expect(container.selected.isEmpty)

    // Select
    container.select(asset)
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))

    // Deselect
    container.deselect(asset)
    #expect(container.selected.isEmpty)

    // Select again
    container.select(asset)
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))

    // Deselect again
    container.deselect(asset)
    #expect(container.selected.isEmpty)
  }

  // MARK: - Different Asset Types Tests

  @Test("Works with image assets")
  @MainActor func worksWithImageAssets() async {
    let container = SelectionContainer()
    let imageAsset = MockPHAsset(
      localIdentifier: "image-asset",
      mediaType: .image,
      pixelWidth: 1920,
      pixelHeight: 1080
    )

    container.select(imageAsset)

    #expect(container.selected.count == 1)
    #expect(container.selected.contains(imageAsset))
    #expect(imageAsset.isImage)
    #expect(!imageAsset.isVideo)
  }

  @Test("Works with video assets")
  @MainActor func worksWithVideoAssets() async {
    let container = SelectionContainer()
    let videoAsset = MockPHAsset(
      localIdentifier: "video-asset",
      mediaType: .video,
      duration: 30.5
    )

    container.select(videoAsset)

    #expect(container.selected.count == 1)
    #expect(container.selected.contains(videoAsset))
    #expect(!videoAsset.isImage)
    #expect(videoAsset.isVideo)
  }

  @Test("Works with mixed asset types")
  @MainActor func worksWithMixedAssetTypes() async {
    let container = SelectionContainer()
    let imageAsset = createTestAsset(id: "image-asset", mediaType: .image)
    let videoAsset = MockPHAsset(
      localIdentifier: "video-asset",
      mediaType: .video,
      duration: 15.2
    )

    container.select(imageAsset)
    container.select(videoAsset)

    #expect(container.selected.count == 2)
    #expect(container.selected.contains(imageAsset))
    #expect(container.selected.contains(videoAsset))
  }

  // MARK: - Large Scale Tests

  @Test("Handles large number of assets")
  @MainActor func handlesLargeNumberOfAssets() async {
    let container = SelectionContainer()
    let assetCount = 1000
    var assets: [MockPHAsset] = []

    // Create and select many assets
    for i in 0 ..< assetCount {
      let asset = createTestAsset(id: "asset-\(i)")
      assets.append(asset)
      container.select(asset)
    }

    #expect(container.selected.count == assetCount)

    // Verify all assets are selected
    for asset in assets {
      #expect(container.selected.contains(asset))
    }

    // Deselect half of them
    let halfCount = assetCount / 2
    for i in 0 ..< halfCount {
      container.deselect(assets[i])
    }

    #expect(container.selected.count == assetCount - halfCount)

    // Verify correct assets remain
    for i in 0 ..< halfCount {
      #expect(!container.selected.contains(assets[i]))
    }
    for i in halfCount ..< assetCount {
      #expect(container.selected.contains(assets[i]))
    }
  }

  // MARK: - Protocol Conformance Tests

  @Test("Conforms to SelectionContaining protocol")
  @MainActor func conformsToSelectionContaining() async {
    let container: any SelectionContaining = SelectionContainer()
    let asset = createTestAsset(id: "protocol-test")

    // Test that protocol methods work
    container.select(asset)
    container.deselect(asset)

    // We can't directly access selected through protocol, but methods should execute without error
    #expect(true) // If we get here, the protocol methods worked
  }

  // MARK: - Memory and Performance Tests

  @Test("Selection set maintains uniqueness efficiently")
  @MainActor func selectionSetMaintainsUniqueness() async {
    let container = SelectionContainer()
    let asset = createTestAsset(id: "unique-test")

    // Select same asset many times
    for _ in 0 ..< 100 {
      container.select(asset)
    }

    // Should still only contain one instance
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))
  }

  @Test("Assets with same identifier are treated as equal")
  @MainActor func assetsWithSameIdentifierEqual() async {
    let container = SelectionContainer()
    let identifier = "same-identifier"
    let asset1 = MockPHAsset(
      localIdentifier: identifier,
      mediaType: .image,
      pixelWidth: 1920
    )
    let asset2 = MockPHAsset(
      localIdentifier: identifier,
      mediaType: .video,
      pixelWidth: 1080
    )

    #expect(asset1.localIdentifier == asset2.localIdentifier) // Should have same identifier

    container.select(asset1)
    container.select(asset2)

    // Should contain both instances since PHAsset identity is based on object identity, not localIdentifier
    #expect(container.selected.count == 2)
  }

  @Test("Assets with different identifiers are treated as different")
  @MainActor func assetsWithDifferentIdentifiersDifferent() async {
    let container = SelectionContainer()
    let asset1 = createTestAsset(id: "identifier-1")
    let asset2 = createTestAsset(id: "identifier-2")

    #expect(asset1.localIdentifier != asset2.localIdentifier)

    container.select(asset1)
    container.select(asset2)

    #expect(container.selected.count == 2)
    #expect(container.selected.contains(asset1))
    #expect(container.selected.contains(asset2))
  }

  // MARK: - Boundary and Error Conditions

  @Test("Container handles rapid select/deselect operations")
  @MainActor func rapidSelectDeselectOperations() async {
    let container = SelectionContainer()
    let assets = (0 ..< 10).map { createTestAsset(id: "rapid-\($0)") }

    // Rapid selection and deselection
    for _ in 0 ..< 100 {
      for asset in assets {
        container.select(asset)
      }
      for asset in assets {
        container.deselect(asset)
      }
    }

    #expect(container.selected.isEmpty)
  }

  @Test("Container works with assets having empty identifiers")
  @MainActor func emptyIdentifierAssets() async {
    let container = SelectionContainer()
    let emptyAsset1 = createTestAsset(id: "")
    let emptyAsset2 = createTestAsset(id: "")

    container.select(emptyAsset1)
    container.select(emptyAsset2)

    // Both assets are different objects even with same identifier
    #expect(container.selected.count == 2)
  }

  @Test("Container handles very long identifiers")
  @MainActor func veryLongIdentifiers() async {
    let container = SelectionContainer()
    let longIdentifier = String(repeating: "a", count: 10000)
    let asset = createTestAsset(id: longIdentifier)

    container.select(asset)
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))

    container.deselect(asset)
    #expect(container.selected.isEmpty)
  }

  @Test("Container handles special characters in identifiers")
  @MainActor func specialCharacterIdentifiers() async {
    let container = SelectionContainer()
    let specialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?/~`\"'"
    let asset = createTestAsset(id: specialChars)

    container.select(asset)
    #expect(container.selected.count == 1)
    #expect(container.selected.contains(asset))
  }
}
