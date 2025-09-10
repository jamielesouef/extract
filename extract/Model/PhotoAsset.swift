//
//  PhotoAsset.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import Foundation
import Photos

/// Protocol abstracting PHAsset functionality for testability and modularity
protocol PhotoAsset: Sendable {
  nonisolated var localIdentifier: String { get }
  nonisolated var mediaType: PHAssetMediaType { get }
  nonisolated var creationDate: Date? { get }
  nonisolated var pixelWidth: Int { get }
  nonisolated var pixelHeight: Int { get }
  nonisolated var duration: TimeInterval { get }
}

// MARK: - PHAsset Conformance

extension PHAsset: PhotoAsset, @unchecked Sendable {
  // PHAsset already provides all required properties
}

// MARK: - Mock Implementation

struct MockPhotoAsset: PhotoAsset, @unchecked Sendable {
  private let _localIdentifier: String
  private let _mediaType: PHAssetMediaType
  private let _creationDate: Date?
  private let _pixelWidth: Int
  private let _pixelHeight: Int
  private let _duration: TimeInterval

  nonisolated var localIdentifier: String { self._localIdentifier }
  nonisolated var mediaType: PHAssetMediaType { self._mediaType }
  nonisolated var creationDate: Date? { self._creationDate }
  nonisolated var pixelWidth: Int { self._pixelWidth }
  nonisolated var pixelHeight: Int { self._pixelHeight }
  nonisolated var duration: TimeInterval { self._duration }

  init(
    localIdentifier: String = UUID().uuidString,
    mediaType: PHAssetMediaType = .image,
    creationDate: Date? = Date(),
    pixelWidth: Int = 1920,
    pixelHeight: Int = 1080,
    duration: TimeInterval = 0.0
  ) {
    self._localIdentifier = localIdentifier
    self._mediaType = mediaType
    self._creationDate = creationDate
    self._pixelWidth = pixelWidth
    self._pixelHeight = pixelHeight
    self._duration = duration
  }

  // Manual Hashable conformance to avoid MainActor isolation
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(self._localIdentifier)
  }

  nonisolated static func == (lhs: MockPhotoAsset, rhs: MockPhotoAsset) -> Bool {
    lhs._localIdentifier == rhs._localIdentifier
  }
}

// MARK: - Convenience Extensions

extension PhotoAsset {
  var isImage: Bool { mediaType == .image }
  var isVideo: Bool { mediaType == .video }

  var aspectRatio: Double {
    guard pixelHeight > 0 else { return 1.0 }
    return Double(pixelWidth) / Double(pixelHeight)
  }
}
