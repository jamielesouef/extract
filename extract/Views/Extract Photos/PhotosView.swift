//
//  PhotosView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Photos
import SwiftData
import SwiftUI

struct PhotosView: View {
  @Environment(MediaStore.self) private var store
  @Environment(AppState.self) private var appState
  @Environment(\.modelContext) private var modelContext

  @State private var isRefreshing = false

  private let size: CGFloat = 100

  private var columns: [GridItem] {
    [GridItem(
      .adaptive(
        minimum: getIdealSizeForimage(),
        maximum: getIdealSizeForimage()
      ),
      spacing: Constants.Image.spacing
    )]
  }

  var body: some View {
    ScrollView {
      LazyVStack {
        PhotosHeaderView(
          count: self.store.count,
          photosCount: self.store.photosCount,
          videoCount: self.store.videoCount
        )
        Divider()
        LazyVGrid(columns: self.columns) {
          ForEach(self.store.items, id: \.localIdentifier) { asset in
            ImageThumbnailView(
              asset: asset,
              size: self.getIdealSizeForimage(),

            )
            .clipShape(RoundedRectangle(cornerSize: .square))
          }
        }
      }
    }
    .ignoresSafeArea(.keyboard)
    .toolbar(removing: .title)
    .showSelectAll()
    .task {
      await self.refreshGuarded()
    }
    .refreshable {
      slog("refresh")
      await self.refreshGuarded()
    }
  }

  private func refreshGuarded() async {
    if self.isRefreshing { return }
    self.isRefreshing = true
    defer { isRefreshing = false }
    await self.getMediaAndIndex()
  }

  private func getMediaAndIndex() async {
    await self.store.requestAndLoad()
//    let indexer = MediaIndex(modelContainer: modelContext.container)
//    do {
//      try await indexer.addMedia(media: self.store.items)
//    } catch {
//      slog(error)
//    }
  }

  private func getIdealSizeForimage() -> CGFloat {
   
    let minWidth = min(appState.windowSize.height, self.appState.windowSize.width)

    return (minWidth / Constants.Image.maxItemsForMinSpace) - Constants.Image.spacing
  }
}

#Preview("Photos Grid with 8 Items") {
  PhotosView()
    .environment(AppState())
    .environment(MediaStore(items: [
      MockPhotoAsset(mediaType: .image),
      MockPhotoAsset(mediaType: .image),
      MockPhotoAsset(mediaType: .video, duration: 30.5),
      MockPhotoAsset(mediaType: .image),
      MockPhotoAsset(mediaType: .image),
      MockPhotoAsset(mediaType: .video, duration: 15.2),
      MockPhotoAsset(mediaType: .image),
      MockPhotoAsset(mediaType: .image)
    ]))
}
