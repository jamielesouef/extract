// MARK: - Photo Loading Service Contract

// Handles efficient loading of photo thumbnails from PhotoKit

import Photos
import SwiftUI

@MainActor
protocol PhotoLoadingServiceProtocol: ObservableObject {
  // MARK: - Authorization

  func requestAuthorization() async -> PHAuthorizationStatus
  var authorizationStatus: PHAuthorizationStatus { get }

  // MARK: - Photo Discovery

  func fetchPhotos() async throws -> [PHAsset]
  func fetchPhotoCount() async throws -> Int

  // MARK: - Thumbnail Loading

  func loadThumbnail(for asset: PHAsset, size: CGSize) async throws -> UIImage
  func loadThumbnails(for assets: [PHAsset], size: CGSize) async throws -> [String: UIImage]
  func cancelThumbnailRequest(for asset: PHAsset)

  // MARK: - Cache Management

  func preloadThumbnails(for assets: [PHAsset], size: CGSize) async
  func evictThumbnails(for assets: [PHAsset])
  func clearThumbnailCache()

  // MARK: - Performance

  var isLoading: Bool { get }
  var loadingProgress: Double { get }
}

// MARK: - Supporting Types

struct ThumbnailRequest {
  let asset: PHAsset
  let size: CGSize
  let deliveryMode: PHImageRequestOptionsDeliveryMode
  let requestID: PHImageRequestID?

  init(asset: PHAsset, size: CGSize, deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic) {
    self.asset = asset
    self.size = size
    self.deliveryMode = deliveryMode
    requestID = nil
  }
}

struct ThumbnailResult {
  let asset: PHAsset
  let image: UIImage?
  let isDegraded: Bool
  let error: Error?
  let loadTime: TimeInterval

  var isSuccess: Bool { image != nil && error == nil }
}

// MARK: - Error Types

enum PhotoLoadingError: LocalizedError {
  case authorizationDenied
  case authorizationRestricted
  case noPhotosFound
  case thumbnailLoadFailed(PHAsset, underlying: Error?)
  case requestCancelled(PHAsset)
  case networkUnavailable
  case insufficientStorage

  var errorDescription: String? {
    switch self {
    case .authorizationDenied:
      return "Photos access denied. Please grant permission in Settings."
    case .authorizationRestricted:
      return "Photos access restricted by device policy."
    case .noPhotosFound:
      return "No photos found in the library."
    case let .thumbnailLoadFailed(asset, underlying):
      return "Failed to load thumbnail for \(asset.localIdentifier): \(underlying?.localizedDescription ?? "Unknown error")"
    case let .requestCancelled(asset):
      return "Thumbnail request cancelled for \(asset.localIdentifier)"
    case .networkUnavailable:
      return "Network unavailable for iCloud photo download."
    case .insufficientStorage:
      return "Insufficient device storage for photo loading."
    }
  }
}

// MARK: - Contract Tests

#if DEBUG
  protocol PhotoLoadingServiceTestProtocol {
    func testAuthorizationRequest() async throws
    func testPhotoFetching() async throws
    func testThumbnailLoading() async throws
    func testConcurrentLoading() async throws
    func testCacheManagement() async throws
    func testErrorHandling() async throws
    func testPerformanceMetrics() async throws
  }
#endif
