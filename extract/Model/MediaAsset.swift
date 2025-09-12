//
//  MediaAsset.swift
//  extract
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Foundation
import Photos

/// A lightweight model that replaces PHAsset for UI layer, decoupling from PhotoKit
struct MediaAsset: Identifiable, Hashable, Sendable {
  let id: String
  let localIdentifier: String // PHAsset's localIdentifier for loading operations
  let mediaType: MediaAssetType
  let creationDate: Date?
  let pixelWidth: Int
  let pixelHeight: Int
  let duration: TimeInterval
  let filename: String?
  let location: CLLocation?

  // Computed properties that replace PHAsset extensions
  var isImage: Bool { mediaType == .image }
  var isVideo: Bool { mediaType == .video }

  var aspectRatio: Double {
    guard pixelHeight > 0 else { return 1.0 }
    return Double(pixelWidth) / Double(pixelHeight)
  }

  /// Create MediaAsset from PHAsset
  init(from phAsset: PHAsset) {
    localIdentifier = phAsset.localIdentifier

    // Generate deterministic ID like PHAsset extension does
    let dateString: String = if let creationDate = phAsset.creationDate {
      creationDate.ISO8601Format()
    } else {
      phAsset.localIdentifier.isEmpty ? "unknown-\(ObjectIdentifier(phAsset).hashValue)" : phAsset.localIdentifier
    }

    let mediaTypeString = phAsset.mediaType == .image ? "photo" : "video"
    let identifier = "\(dateString)-\(mediaTypeString)-\(phAsset.pixelWidth)x\(phAsset.pixelHeight)-\(phAsset.duration)"
    id = identifier.replacingOccurrences(of: ":", with: "-")

    mediaType = MediaAssetType(from: phAsset.mediaType)
    creationDate = phAsset.creationDate
    pixelWidth = phAsset.pixelWidth
    pixelHeight = phAsset.pixelHeight
    duration = phAsset.duration
    filename = phAsset.value(forKey: "filename") as? String
    location = phAsset.location
  }

  /// Create MediaAsset for testing
  init(
    id: String = UUID().uuidString,
    localIdentifier: String = UUID().uuidString,
    mediaType: MediaAssetType = .image,
    creationDate: Date? = nil,
    pixelWidth: Int = 1920,
    pixelHeight: Int = 1080,
    duration: TimeInterval = 0.0,
    filename: String? = nil,
    location: CLLocation? = nil
  ) {
    self.id = id
    self.localIdentifier = localIdentifier
    self.mediaType = mediaType
    self.creationDate = creationDate
    self.pixelWidth = pixelWidth
    self.pixelHeight = pixelHeight
    self.duration = duration
    self.filename = filename
    self.location = location
  }

  // MARK: - Hashable & Equatable

  static func == (lhs: MediaAsset, rhs: MediaAsset) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

enum MediaAssetType: String, Codable, Sendable, CaseIterable {
  case image
  case video
  case audio
  case unknown

  init(from phAssetMediaType: PHAssetMediaType) {
    switch phAssetMediaType {
    case .image: self = .image
    case .video: self = .video
    case .audio: self = .audio
    case .unknown: self = .unknown
    @unknown default: self = .unknown
    }
  }

  var phAssetMediaType: PHAssetMediaType {
    switch self {
    case .image: .image
    case .video: .video
    case .audio: .audio
    case .unknown: .unknown
    }
  }
}

// MARK: - Collection Extensions

extension [MediaAsset] {
  var imageCount: Int {
    count(where: { $0.isImage })
  }

  var videoCount: Int {
    count(where: { $0.isVideo })
  }
}
