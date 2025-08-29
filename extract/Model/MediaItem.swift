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
class MediaItem {

  enum Kind: String, Codable { case image, video, audio, livePhoto, unknown }

  var id: UUID
  var mediaId: String
  var kind: Kind
  var filename: String?
  
  init(id: UUID = .init(), mediaId: String, kind: Kind, filename: String? = nil) {
    self.id = id
    self.mediaId = mediaId
    self.kind = kind
    self.filename = filename
  }
}
