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

  var items: [MediaAsset] = []
  var authorizationStatus: Bool?
  var isLoading = false
  var count: Int { items.count }
  var photosCount = 0
  var videoCount = 0

  var isInSelectMode = false

  @ObservationIgnored private(set) var selectionContainer: SelectionContainer?

  // Static formatter for thread-safe reuse
  private nonisolated(unsafe) static let iso8601Formatter = ISO8601DateFormatter()

  private(set) var selected: Set<AnyHashable> = []

  init(items: [MediaAsset] = [],
       authorizer: PhotoLibraryAuthorizing = SystemPhotoLibraryAuthorizer())
  {
    self.items = items
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
      let items: [MediaAsset]
      let photosCount: Int
      let videoCount: Int
    }

    let result = await Task.detached(priority: .high) { () -> LoadResult in
      try? Task.checkCancellation()

      let options = PHFetchOptions()
      options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      let fetched = PHAsset.fetchAssets(with: options)

      var localItems: [MediaAsset] = []
      var localPhotosCount = 0
      var localVideoCount = 0

      localItems.reserveCapacity(fetched.count)

      fetched.enumerateObjects { phAsset, _, _ in
        let mediaAsset = MediaAsset(from: phAsset)

        switch mediaAsset.mediaType {
        case .image: localPhotosCount += 1
        case .video: localVideoCount += 1
        case .audio, .unknown: break
        }

        localItems.append(mediaAsset)
      }

      return LoadResult(items: localItems,
                        photosCount: localPhotosCount,
                        videoCount: localVideoCount)
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

  func createSelectionContainer() {
    if selectionContainer == nil {
      selectionContainer = .init()
    }
  }

  func resetSelectionContainer() {
    selectionContainer = nil
  }

  func selectAll() {}

  func selectNone() {}
}
