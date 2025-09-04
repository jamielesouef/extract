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

  let asset: PHAsset
  let size: CGFloat

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
    .onAppear { loadImageIfNeeded() }
    .onDisappear { cancelIfNeeded() }
  }

  private func loadImageIfNeeded() {
    if image != nil { return }
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.resizeMode = .fast

    let targetSize = CGSize(width: size * displayScale, height: size * displayScale)

    requestID = PHImageManager.default().requestImage(
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

#Preview {
  ImageThumbnailView(asset: .init(), size: 100)
}
