//
//  PHAsset+Extension.swift
//  extract
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Photos

extension PHAsset: @retroactive Identifiable {
  public var id: String {
    let dateString: String = if let creationDate {
      creationDate.ISO8601Format()
    } else {
      localIdentifier.isEmpty ? "unknown-\(ObjectIdentifier(self).hashValue)" : localIdentifier
    }

    let mediaType = mediaType == .image ? "photo" : "video"
    let pixelWidth = pixelWidth
    let pixelHeight = pixelHeight
    let duration = duration

    let identifier = "\(dateString)-\(mediaType)-\(pixelWidth)x\(pixelHeight)-\(duration)"
    return identifier.replacingOccurrences(of: ":", with: "-")
  }
  
  public var uuid: UUID {
    .init()
  }
}
