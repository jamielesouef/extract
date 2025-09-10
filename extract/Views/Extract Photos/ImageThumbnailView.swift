//
//  ImageThumbnailView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Photos
import SwiftUI
#if os(macOS)
  import AppKit
#endif

struct ImageThumbnailView: View {
  @Environment(\.displayScale) private var displayScale
  @Environment(MediaStore.self) private var store

  // Allow nil in previews to avoid needing a real PHAsset
  let asset: PHAsset?
  let size: CGFloat
  let isInSelectMode: Bool

  #if os(iOS)
    @State private var image: UIImage?
  #else
    @State private var image: NSImage?
  #endif

  @State private var requestID: PHImageRequestID?

  var body: some View {
    Group {
      if let image {
        #if os(iOS)
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        #else
          Image(nsImage: image)
            .resizable()
            .scaledToFill()
        #endif
      } else {
        Color.gray.opacity(0.2)
      }
    }
    .frame(width: size, height: size)
    .clipped()
    .task { await loadImageIfNeeded() }
    .onDisappear { cancelIfNeeded() }
  }

  private func loadImageIfNeeded() async {
    if image != nil { return }
    guard let asset else { return }
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.resizeMode = .fast

    let targetSize = CGSize(width: size * displayScale, height: size * displayScale)

    requestID = PHCachingImageManager.default().requestImage(
      for: asset,
      targetSize: targetSize,
      contentMode: .aspectFill,
      options: options
    ) { img, _ in
      image = img
    }
  }

  private func cancelIfNeeded() {
    if let id = requestID {
      PHImageManager.default().cancelImageRequest(id)
      requestID = nil
    }
  }
}

// MARK: - Inits

extension ImageThumbnailView {
  // Keep a non-optional API for production call sites
  init(asset: PHAsset, size: CGFloat, isInSelectMode: Bool) {
    self.asset = asset
    self.size = size
    self.isInSelectMode = isInSelectMode
  }
}

#if DEBUG

  // MARK: - Previews

  @available(iOS 17.0, macOS 14.0, *)
  #Preview("Selected vs Unselected") {
    HStack(spacing: 16) {
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100, isInSelectMode: false)
        Text("Select Off").font(.caption).foregroundStyle(.secondary)
      }
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100, isInSelectMode: true)
        Text("Select On").font(.caption).foregroundStyle(.secondary)
      }
    }
    .padding()
    .environment(MediaStore())
  }
#endif
