//
//  ImageThumbnailView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import SwiftUI
import Photos

struct ImageThumbnailView: View {

  @Environment(\.displayScale) private var displayScale

  let asset: PHAsset
  let size: CGFloat = 30

  @State private var image: UIImage?
  @State private var requestID: PHImageRequestID?

  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else {
        Color.gray.opacity(0.2)
      }
    }
    .frame(width: size , height: size)
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
  ImageThumbnailView(asset: .init())
}
