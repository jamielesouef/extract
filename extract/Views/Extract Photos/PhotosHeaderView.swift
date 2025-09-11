//
//  PhotosHeaderView.swift
//  extract
//
//  Created by Jamie Le Souef on 2/9/2025.
//

import SwiftUI

struct PhotosHeaderView: View {
  @Environment(\.displayScale) private var displayScale: CGFloat
  @Environment(AppState.self) private var appState
  @Environment(MediaStore.self) private var store

  @State private var imageLoader = ImageLoader()

  private let textOpacity: CGFloat = 0.8

  var body: some View {
    if store.isLoading {
      Text("loading")
    } else {
      Image(unsafePlatformAgnosticImage: imageLoader.image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 0,
               maxHeight: .infinity)
        .clipped()
      #if os(iOS)
        .backgroundExtensionEffect()
      #endif
        .task {
          await loadImage()
        }
        .overlay(alignment: .bottom) {
          VStack {
            Text("Media")
              .font(.subheadline)
              .fontWeight(.bold)
              .foregroundStyle(.white)
              .opacity(textOpacity)

            Text(
              "\(store.photosCount.formatted()) photos, \(store.videoCount.formatted()) videos"
            )
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding([.leading, .trailing])

            Button(action: {}) {
              Text("Backup now")
            }
            #if os(iOS)
            .glassEffect()
            #endif
            .buttonStyle(.borderedProminent)
            .padding([.bottom, .top], Constants.Image.padding)
          }
        }
    }
  }

  private func loadImage() async {
    if let asset = store.items.first {
      await imageLoader.loadImage(from: asset, with: appState.windowSize.width, at: displayScale)
    }
  }
}

//
// #Preview("Landscape Image") {
//  PhotosHeaderView(count: 1234, photosCount: 1000, videoCount: 234, image: "cat-landscape")
//    .frame(height: 440)
// }
//
// #Preview("Portrate Image") {
//  PhotosHeaderView(count: 1234, photosCount: 1000, videoCount: 234, image: "cat-portrait")
//    .frame(height: 440)
// }
