// MARK: - Photos Service Contract

// Handles Photos library access and asset retrieval

import Foundation
import Photos

@MainActor
protocol PhotosServiceProtocol: ObservableObject {
  // MARK: - Authorization

  func requestAuthorization() async -> PHAuthorizationStatus
  var authorizationStatus: PHAuthorizationStatus { get }

  // MARK: - Asset Discovery

  func fetchAssets(for selection: SelectionSpec) async throws -> [PHAsset]
  func fetchAssetCount(for selection: SelectionSpec) async throws -> Int
  func estimateDataSize(for assets: [PHAsset]) async throws -> Int64

  // MARK: - Asset Processing

  func requestOriginalResource(for asset: PHAsset) async throws -> AssetResource
  func requestOriginalResources(
    for assets: [PHAsset],
    progressHandler: @escaping (Double) -> Void
  ) async throws
    -> [AssetResource]

  // MARK: - Library Monitoring

  func startObservingLibraryChanges()
  func stopObservingLibraryChanges()
}

// MARK: - Supporting Types

struct AssetResource {
  let asset: PHAsset
  let data: Data
  let uti: String?
  let filename: String
  let isFromCloud: Bool
  let requestedAt: Date

  var fileExtension: String {
    URL(string: self.filename)?.pathExtension ?? ""
  }

  var mediaType: MediaType {
    switch self.asset.mediaType {
    case .image:
      if self.asset.mediaSubtypes.contains(.photoLive) {
        return .livePhoto
      } else if self.asset.mediaSubtypes.contains(.photoScreenshot) {
        return .screenshot
      } else if self.asset.mediaSubtypes.contains(.photoPanorama) {
        return .panorama
      } else if self.asset.mediaSubtypes.contains(.photoDepthEffect) {
        return .portraitPhoto
      } else {
        return .photo
      }
    case .video:
      if self.asset.mediaSubtypes.contains(.videoTimelapse) {
        return .timelapse
      } else if self.asset.mediaSubtypes.contains(.videoHighFrameRate) {
        return .slowMotion
      } else {
        return .video
      }
    case .audio:
      return .unknown
    case .unknown:
      return .unknown
    @unknown default:
      return .unknown
    }
  }
}

// MARK: - Error Types

enum PhotosServiceError: LocalizedError {
  case authorizationDenied
  case authorizationRestricted
  case assetNotFound(String)
  case resourceRequestFailed(String)
  case networkUnavailable
  case iCloudSyncRequired
  case insufficientStorage
  case libraryUnavailable

  var errorDescription: String? {
    switch self {
    case .authorizationDenied:
      "Photos access denied. Please grant permission in Settings."
    case .authorizationRestricted:
      "Photos access restricted by device policy."
    case let .assetNotFound(identifier):
      "Photo asset not found: \(identifier)"
    case let .resourceRequestFailed(reason):
      "Failed to load photo: \(reason)"
    case .networkUnavailable:
      "Network unavailable for iCloud photo download."
    case .iCloudSyncRequired:
      "iCloud Photos sync required to access originals."
    case .insufficientStorage:
      "Insufficient device storage to download photos from iCloud."
    case .libraryUnavailable:
      "Photos library is currently unavailable."
    }
  }
}

// MARK: - Contract Tests

#if DEBUG
  protocol PhotosServiceTestProtocol {
    func testAuthorizationRequest() async throws
    func testAssetFetching() async throws
    func testResourceRetrieval() async throws
    func testLibraryMonitoring() async throws
    func testErrorHandling() async throws
  }
#endif
