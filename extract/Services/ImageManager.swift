//
//  ImageManager.swift
//  extract
//
//  Created by Jamie Le Souef on 11/9/2025.
//

import Photos
import SwiftUI

@Observable
final class ImageManager {
  #if os(iOS)
    private(set) var image: UIImage?
  #else
    private(set) var image: NSImage?
  #endif

  private(set) var requestID: PHImageRequestID?

  func loadImage(from asset: PhotoAsset, with size: CGFloat, at displayScale: CGFloat) async {
    guard image == nil else { return }
    // Only load images for PHAsset instances (not mock assets in previews)
    guard let phAsset = asset as? PHAsset else { return }

    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.resizeMode = .fast

    let targetSize = CGSize(
      width: size * displayScale,
      height: size * displayScale
    )

    requestID = PHCachingImageManager.default().requestImage(
      for: phAsset,
      targetSize: targetSize,
      contentMode: .aspectFill,
      options: options
    ) { [weak self] img, _ in
      self?.image = img
    }
  }

  func cancel() {
    if let id = requestID {
      PHImageManager.default().cancelImageRequest(id)
      requestID = nil
    }
  }
}
