//
//  MediaItem.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Photos
import AVFoundation
import SwiftData

@Model
nonisolated final class MediaItem {

  @Attribute(.unique) var id: UUID
  var mediaId: String
  var kind: MediaItemData.Kind
  var status: MediaItemData.Status
  var filename: String?

  init(
    mediaId: String,
    kind: MediaItemData.Kind,
    status: MediaItemData.Status,
    filename: String? = nil
  ) {
    self.id = UUID()
    self.mediaId = mediaId
    self.kind = kind
    self.status = status
    self.filename = filename
  }
}

struct MediaItemData: Sendable {

  enum Kind: String, Codable, Sendable {
    case image,
         video,
         audio,
         livePhoto,
         unknown
  }

  enum Status: String, Codable, Sendable {
    case backedUp, notBackedUp, unknown
  }

  let mediaId: String
  let kind: Kind
  let status: Status
  let filename: String?
}
