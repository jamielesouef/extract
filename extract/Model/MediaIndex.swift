//
//  MediaIndex.swift
//  extract
//
//  Created by Jamie Le Souef on 29/8/2025.
//

import SwiftUI
import SwiftData
import Photos

@ModelActor
actor MediaIndex {

  func addMedia(media items: [PHAsset]) async throws {
    let mediaItems = items.map {
      let kind =  getMediaType(from: $0.mediaType)
      return MediaItemData(
        mediaId: $0.localIdentifier,
        kind: kind,
        status: .unknown,
        filename: nil
      )
    }

    try await addMedia(media: mediaItems)
  }

  func addMedia(media items: [MediaItemData]) async throws {

    let descriptor = FetchDescriptor<MediaItem>()

    let existing: [MediaItem] = try modelContext.fetch(descriptor)
    var existingIDs: Set<String> = Set(existing.map { $0.mediaId })

    for item in items {
      let id = item.mediaId
      if existingIDs.contains(id) { continue }

      let copy = MediaItem(
        mediaId: id,
        kind: item.kind,
        status: item.status
      )

      modelContext.insert(copy)
      existingIDs.insert(id)
    }

    try modelContext.save()
  }

  private func getMediaType(from type: PHAssetMediaType) -> MediaItemData.Kind {
    switch type {
    case .image: return .image
    case .video: return .video
    case .unknown: return .unknown
    case .audio: return .audio
    @unknown default: return .unknown
    }
  }
}

/*
 Optional("FD8B1F77-1618-4B3E-8F74-C939B1AB1945/L0/001")
 Optional("CD230B59-A705-41AF-88FD-9767B7C43B66/L0/001")
 */
