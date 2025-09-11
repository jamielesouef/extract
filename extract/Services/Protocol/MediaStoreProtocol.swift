//
//  MediaStoreProtocol.swift
//  extract
//
//  Created by Jamie Le Souef on 9/9/2025.
//

import Foundation
import Photos

protocol MediaIndexing: Sendable {
  func addMedia(media items: [any PhotoAsset]) async throws
  func addMedia(media items: [MediaItemData]) async throws
}
