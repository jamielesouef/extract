//
//  PhotosView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import SwiftUI
import Photos

struct PhotosView: View {
  @Environment(PhotosStore.self) var store
  @Environment(AppState.self) var appState
  
  private let spacing: CGFloat = 8
  private let size: CGFloat = 100
  private let roundedRadius = CGSize(width: 8, height: 8)
  
  private var columns: [GridItem] {
    [GridItem(.adaptive(minimum: 100), spacing: spacing)]
  }
  
  var body: some View {
    ScrollView {
      LazyVStack {
        Text("total: \(store.count)")
        Text("Photos: \(store.photosCount.formatted()), Videos: \(store.videoCount.formatted())")
        Text("Media items since last backup")
        Divider()
        LazyVGrid(columns: columns) {
          ForEach(store.items, id: \.self) { asset in
            ImageThumbnailView(asset: asset, size: getIdealSizeForimage())
              .clipShape(RoundedRectangle(cornerSize: roundedRadius))
          }
        }
      }
      .task {
        await store.requestAndLoad()
      }
    }
    .ignoresSafeArea(.keyboard)
    .toolbar(removing: .title)
    
  }
  
  private func getIdealSizeForimage() -> CGFloat {
    let maxWidthForIPhone: CGFloat = 3
    let delta = min(appState.windowSize.height, appState.windowSize.width) / maxWidthForIPhone
    return delta - (spacing * 2)
  }
}

#Preview {
  PhotosView()
    .environment(AppState())
    .environment(PhotosStore())
}
