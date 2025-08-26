//
//  PhotosStore.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Foundation
import Photos

@Observable @MainActor
final class PhotosStore {

  var items: [PHAsset] = []
  var authorizationStatus: Bool?

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
}
