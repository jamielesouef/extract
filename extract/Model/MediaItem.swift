import Photos
import AVFoundation

struct MediaItem: Identifiable, Hashable {
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
  let exif: [String: Any]
  let iptc: [String: Any]
  let tiff: [String: Any]
  let gps: [String: Any]
  let videoMetadata: [String: String]
}