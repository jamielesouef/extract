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
//  @Environment(\.modelContext) private var modelContext

  @State private var isRefreshing = false

  private let size: CGFloat = 100

  private var columns: [GridItem] {
    [
      GridItem(
        .adaptive(
          minimum: getIdealSizeForimage(),
          maximum: getIdealSizeForimage()
        ),
        spacing: Constants.Image.spacing
      )
    ]
  }

  var body: some View {
    ScrollView {
      LazyVStack {
        PhotosHeaderView()
          .photosHeaderViewFlexableModifider()

        LazyVGrid(columns: columns) {
          ForEach(store.items, id: \.localIdentifier) { asset in
            ImageThumbnailView(
              asset: asset,
              size: getIdealSizeForimage()
            )
          }
        }
      }
    }
    .ignoresSafeArea(.keyboard)
    .ignoresSafeArea(.all)
    .toolbar(removing: .title)
    .showSelectAll()
    .scrollViewGeometryReaader()
    .task {
//      await refreshGuarded()
    }
    .refreshable {
      slog("refresh")
//      await refreshGuarded()
    }
  }

  private func refreshGuarded() async {
    if isRefreshing { return }
    isRefreshing = true
    defer { isRefreshing = false }
    await getMediaAndIndex()
  }

  private func getMediaAndIndex() async {
    await store.requestAndLoad()
    //    let indexer = MediaIndex(modelContainer: modelContext.container)
    //    do {
    //      try await indexer.addMedia(media: store.items)
    //    } catch {
    //      slog(error)
    //    }
  }

  private func getIdealSizeForimage() -> CGFloat {
    let minWidth = min(appState.windowSize.height, appState.windowSize.width)

    guard minWidth > 0 else { return Constants.Image.idealImageSize }

    return (minWidth / Constants.Image.maxItemsForMinSpace)
      - Constants.Image.spacing
  }
}

#Preview("Photos Grid with 8 Items") {
  @Previewable @State var appState = AppState()
  @Previewable @State var store = MediaStore(items: [
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset(),
    MockPhotoAsset()
  ])

  PhotosView()
    .onGeometryChange(for: CGFloat.self, of: { proxy in
      min(proxy.size.width, proxy.size.height)
    }, action: {
      appState.windowSize = CGSize(width: $0, height: $0)
    })
    .modelContainer(for: MediaItem.self, inMemory: true)
    .environment(appState)
    .environment(store)
}
