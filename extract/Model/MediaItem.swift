//
//  MediaItem.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//


import Photos
import AVFoundation

struct MediaItem: Identifiable {

  struct Metadata {
    let exif: [String: Any]
    let iptc: [String: Any]
    let tiff: [String: Any]
    let gps: [String: Any]
  }

  enum Kind: String { case image, video, audio, livePhoto, unknown }
  let id: String
  let kind: Kind
  let filename: String?
  let uti: String?
  let byteSize: Int64?
  let creationDate: Date?
  let modificationDate: Date?
  let duration: Double
  let pixelWidth: Int
  let pixelHeight: Int
  let metaData: Metadata
  let videoMetadata: [String: String]
}

extension MediaItem {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension MediaItem: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
