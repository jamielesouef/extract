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
final class MediaItem {

  enum Kind: String, Codable, Sendable {
    case image,
         video,
         audio,
         livePhoto,
         unknown
  }
  
  enum Status: String, Codable {
    case backedup, notBackedUp, unknown
  }

  var id: UUID
  var mediaId: String
  var kind: Kind
  var status: Status
  var filename: String?
  
  init(
    id: UUID = .init(),
    mediaId: String,
    kind: Kind,
    status: Status,
    filename: String? = nil
  ) {
    self.id = id
    self.mediaId = mediaId
    self.kind = kind
    self.status = status
    self.filename = filename
  }
}
