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
  @Environment(\.displayScale) private var displayScale: CGFloat
  @Environment(MediaStore.self) private var store

  @State private var imageLoader = ImageLoader()
  @State private var isSelected = false

  let asset: PHAsset?
  let size: CGFloat

  var body: some View {
    Group { thumbnailImage }
      .frame(width: size, height: size)
      .overlay { selectionOverlay }
      .clipShape(RoundedRectangle(cornerSize: .square))
      .onTapGesture { toggleSelected() }
      .task { await loadImageIfNeeded() }
      .onDisappear { cancelIfNeeded() }
  }

  @ViewBuilder
  var thumbnailImage: some View {
    if let image = imageLoader.image {
      Image(unsafePlatformAgnosticImage: image)
        .resizable()
        .scaledToFill()
    } else {
      Color.gray.opacity(0.2)
    }
  }

  @ViewBuilder
  var selectionOverlay: some View {
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
          #if os(iOS)
            .glassEffect(.identity)
          #endif
        }
      }
    }
  }

  private func toggleSelected() {
    if store.isInSelectMode {
      isSelected.toggle()
    }
  }

  private func loadImageIfNeeded() async {
    guard let asset else { return }
    await imageLoader.loadImage(from: asset, with: size, at: displayScale)
  }

  private func cancelIfNeeded() {
    imageLoader.cancel()
  }
}

// MARK: - Inits

extension ImageThumbnailView {
  // Keep a non-optional API for production call sites
  init(asset: PHAsset, size: CGFloat) {
    self.asset = asset
    self.size = size
  }
}

#if DEBUG

  // MARK: - Previews

  @available(iOS 17.0, macOS 14.0, *)
  #Preview("Selected vs Unselected") {
    @Previewable @State var store = MediaStore()
    @Previewable @State var store_notSelected = MediaStore()

    store.isInSelectMode = true
    store_notSelected.isInSelectMode = false
    return HStack(spacing: 16) {
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100)
          .environment(store_notSelected)
        Text("Select Off").font(.caption).foregroundStyle(.secondary)
      }
      VStack(spacing: 6) {
        ImageThumbnailView(asset: nil, size: 100)
          .environment(store)
        Text("Select On").font(.caption).foregroundStyle(.secondary)
      }
    }
    .padding()
  }
#endif
