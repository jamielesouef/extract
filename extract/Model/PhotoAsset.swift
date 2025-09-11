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

  nonisolated var localIdentifier: String { _localIdentifier }
  nonisolated var mediaType: PHAssetMediaType { _mediaType }
  nonisolated var creationDate: Date? { _creationDate }
  nonisolated var pixelWidth: Int { _pixelWidth }
  nonisolated var pixelHeight: Int { _pixelHeight }
  nonisolated var duration: TimeInterval { _duration }

  init(localIdentifier: String = UUID().uuidString,
       mediaType: PHAssetMediaType = .image,
       creationDate: Date? = Date(),
       pixelWidth: Int = 1920,
       pixelHeight: Int = 1080,
       duration: TimeInterval = 0.0)
  {
    _localIdentifier = localIdentifier
    _mediaType = mediaType
    _creationDate = creationDate
    _pixelWidth = pixelWidth
    _pixelHeight = pixelHeight
    _duration = duration
  }

  // Manual Hashable conformance to avoid MainActor isolation
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(_localIdentifier)
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
