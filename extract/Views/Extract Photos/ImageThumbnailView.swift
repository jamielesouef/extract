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

  let asset: (any PhotoAsset)?
  let size: CGFloat

  #if os(iOS)
    @State private var image: UIImage?
  #else
    @State private var image: NSImage?
  #endif

  @State private var requestID: PHImageRequestID?
  @State private var isSelected: Bool = false

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
    .frame(width: self.size, height: self.size)
    .overlay {
      VStack {
        Spacer()
        HStack {
          Spacer()
          if store.isInSelectMode {
            Image(
              systemName: isSelected
                ? "checkmark.circle.fill"
                : "circle"
            )
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(6)
            .glassEffect(.identity)
          }
        }
      }
    }
    .onTapGesture {
      if store.isInSelectMode {
        isSelected.toggle()
      }
    }
    .clipped()
    .task { await self.loadImageIfNeeded() }
    .onDisappear { self.cancelIfNeeded() }
  }

  private func loadImageIfNeeded() async {
    if self.image != nil { return }
    guard let asset else { return }

    // Only load images for PHAsset instances (not mock assets in previews)
    guard let phAsset = asset as? PHAsset else { return }

    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.resizeMode = .fast

    let targetSize = CGSize(
      width: size * self.displayScale,
      height: self.size * self.displayScale
    )

    self.requestID = PHCachingImageManager.default().requestImage(
      for: phAsset,
      targetSize: targetSize,
      contentMode: .aspectFill,
      options: options
    ) { img, _ in
      self.image = img
    }
  }

  private func cancelIfNeeded() {
    if let id = requestID {
      PHImageManager.default().cancelImageRequest(id)
      self.requestID = nil
    }
  }
}

// MARK: - Inits

extension ImageThumbnailView {
  // Keep a non-optional API for production call sites
  init(asset: any PhotoAsset, size: CGFloat) {
    self.asset = asset
    self.size = size
  }
}

#if DEBUG

  // MARK: - Previews

  @available(iOS 17.0, macOS 14.0, *)
  #Preview("Selected vs Unselected") {
    @Previewable @State var store = MediaStore()

    store.isInSelectMode = true
    return HStack(spacing: 16) {
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100)
        Text("Select Off").font(.caption).foregroundStyle(.secondary)
      }
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100)
        Text("Select On").font(.caption).foregroundStyle(.secondary)
      }
    }
    .padding()
    .environment(store)
  }
#endif
