//
//  PhotoAsset.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import Foundation
import Photos

// MARK: - PHAsset Extensions

extension PHAsset {
  var isImage: Bool { mediaType == .image }
  var isVideo: Bool { mediaType == .video }

  var aspectRatio: Double {
    guard pixelHeight > 0 else { return 1.0 }
    return Double(pixelWidth) / Double(pixelHeight)
  }
}
