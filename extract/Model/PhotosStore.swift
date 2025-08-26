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

@Observable @MainActor
final class PhotosStore {

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
      break
    case .denied, .notDetermined, .restricted:
      authorizationStatus = false
    @unknown default:
      authorizationStatus = false
    }
  }

  func loadAllAssets() async {
    isLoading = true
    defer { isLoading = false }
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let fetched = PHAsset.fetchAssets(with: options)

    items.reserveCapacity(fetched.count)

    fetched.enumerateObjects { [weak self] asset, id, _ in
      switch asset.mediaType {
      case .image: self?.photosCount += 1
      case .video: self?.videoCount += 1
        default : break
      }
      self?.items.append(asset)
    }
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
