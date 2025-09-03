//
//  PhotosView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import SwiftUI
import Photos
import SwiftData

struct PhotosView: View {

  @Environment(MediaStore.self) private var store
  @Environment(AppState.self) private var appState
  @Environment(\.modelContext) private var modelContext

  @State private var isRefreshing = false

  private let spacing: CGFloat = 8
  private let size: CGFloat = 100
  private let roundedRadius = CGSize(width: 8, height: 8)

  private var columns: [GridItem] {
    [GridItem(.adaptive(minimum: 100), spacing: spacing)]
  }

  var body: some View {
    ScrollView {
      LazyVStack {
        PhotosHeaderView(
          count: store.count,
          photosCount: store.photosCount,
          videoCount: store.videoCount
        )
        Divider()
        LazyVGrid(columns: columns) {
          ForEach(store.items, id: \.self) { asset in
            ImageThumbnailView(asset: asset, size: getIdealSizeForimage())
              .clipShape(RoundedRectangle(cornerSize: roundedRadius))
          }
        }
      }
    }
    .ignoresSafeArea(.keyboard)
    .toolbar(removing: .title)
    .task {
      await refreshGuarded()
    }
    .refreshable {
      slog("refresh")
      await refreshGuarded()
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
    let indexer = MediaIndex(modelContainer: modelContext.container)
    do {
      try await indexer.addMedia(media: store.items)
    } catch {
      slog(error)
    }
  }

  private func getIdealSizeForimage() -> CGFloat {
    let maxWidthForIPhone: CGFloat = 3
    let minWidowSize = min(appState.windowSize.height, appState.windowSize.width) / maxWidthForIPhone
    return minWidowSize - (spacing * 2)
  }
}

#Preview {
  PhotosView()
    .environment(AppState())
    .environment(MediaStore())
}
