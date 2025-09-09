//
//  MediaStore.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import AVFoundation
import Foundation
import ImageIO
import Photos

protocol PhotoLibraryAuthorizing: Sendable {
  func requestAuthorization(for level: PHAccessLevel) async -> PHAuthorizationStatus
}

struct SystemPhotoLibraryAuthorizer: PhotoLibraryAuthorizing {
  func requestAuthorization(for level: PHAccessLevel) async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: level)
  }
}

@Observable
@MainActor
final class MediaStore: MediaStoring {
  private let authorizer: PhotoLibraryAuthorizing

  var items: [PHAsset] = []
  var authorizationStatus: Bool?
  var isLoading: Bool = false
  var count: Int { items.count }
  var photosCount: Int = 0
  var videoCount: Int = 0

  private(set) var selected: Set<PHAsset> = []

  init(authorizer: PhotoLibraryAuthorizing = SystemPhotoLibraryAuthorizer()) {
    self.authorizer = authorizer
  }

  func requestAccess() async {
    let status = await authorizer.requestAuthorization(for: .readWrite)

    switch status {
    case .authorized, .limited:
      authorizationStatus = true
    case .denied, .notDetermined, .restricted:
      authorizationStatus = false
    @unknown default:
      authorizationStatus = false
    }
  }

  func loadAllAssets() async {
    isLoading = true
    defer { isLoading = false }

    struct LoadResult {
      let items: [PHAsset]
      let photosCount: Int
      let videoCount: Int
    }

    let result = await Task.detached(priority: .high) { () -> LoadResult in
      try? Task.checkCancellation()

      let options = PHFetchOptions()
      options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      let fetched = PHAsset.fetchAssets(with: options)

      var localItems: [PHAsset] = []
      var localPhotosCount = 0
      var localVideoCount = 0

      localItems.reserveCapacity(fetched.count)

      fetched.enumerateObjects { asset, _, _ in
        switch asset.mediaType {
        case .image: localPhotosCount += 1
        case .video: localVideoCount += 1
        default: break
        }
        localItems.append(asset)
      }

      return LoadResult(items: localItems, photosCount: localPhotosCount, videoCount: localVideoCount)
    }.value

    items = result.items
    photosCount = result.photosCount
    videoCount = result.videoCount
  }

  func requestAndLoad() async {
    await requestAccess()
    if authorizationStatus == true {
      await loadAllAssets()
    } else {
      items = []
    }
  }

  func getCloudIdentifier(for asset: PHAsset) async -> String? {
    return await Task.detached {
      guard let creationDate = asset.creationDate else {
        return asset.localIdentifier
      }

      let dateFormatter = ISO8601DateFormatter()
      let dateString = dateFormatter.string(from: creationDate)
      let mediaType = asset.mediaType == .image ? "photo" : "video"
      let pixelWidth = asset.pixelWidth
      let pixelHeight = asset.pixelHeight
      let duration = asset.duration

      let identifier = "\(dateString)-\(mediaType)-\(pixelWidth)x\(pixelHeight)-\(duration)"
      return identifier.replacingOccurrences(of: ":", with: "-")
    }.value
  }
}
