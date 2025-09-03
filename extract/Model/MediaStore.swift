//
//  PhotosStore.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Foundation
import Photos
import ImageIO
import AVFoundation

@Observable
@MainActor
final class MediaStore {

  var items: [PHAsset] = []
  var authorizationStatus: Bool?
  var isLoading: Bool = false
  var count: Int { items.count }
  var photosCount: Int = 0
  var videoCount: Int = 0

  func requestAccess() async {

    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)

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
      var localPhotosCount: Int = 0
      var localVideoCount: Int = 0

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
}
