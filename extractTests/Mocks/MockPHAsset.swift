//
//  MockPHAsset.swift
//  extract
//
//  Created by Jamie Le Souef on 12/9/2025.
//

import Photos

final class MockPHAsset: PHAsset, @unchecked Sendable {
  private let _localIdentifier: String
  private let _mediaType: PHAssetMediaType
  private let _creationDate: Date?
  private let _pixelWidth: Int
  private let _pixelHeight: Int
  private let _duration: TimeInterval

  init(
    localIdentifier: String = UUID().uuidString,
    mediaType: PHAssetMediaType = .image,
    creationDate: Date? = Date(),
    pixelWidth: Int = 1920,
    pixelHeight: Int = 1080,
    duration: TimeInterval = 0.0
  ) {
    _localIdentifier = localIdentifier
    _mediaType = mediaType
    _creationDate = creationDate
    _pixelWidth = pixelWidth
    _pixelHeight = pixelHeight
    _duration = duration
    super.init()
  }

  override var localIdentifier: String { _localIdentifier }
  override var mediaType: PHAssetMediaType { _mediaType }
  override var creationDate: Date? { _creationDate }
  override var pixelWidth: Int { _pixelWidth }
  override var pixelHeight: Int { _pixelHeight }
  override var duration: TimeInterval { _duration }
}
