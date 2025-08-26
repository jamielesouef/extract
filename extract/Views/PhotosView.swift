//
//  PhotosView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import SwiftUI

struct PhotosView: View {
  @Environment(PhotosStore.self) var store
  @Environment(AppState.self) var appState

  var body: some View {
    VStack {
      Text("total: \(store.count)")
      Text("Photos: \(store.photosCount.formatted()), Videos: \(store.videoCount.formatted())")
      Text("Media items since last backup")
      Divider()
      ScrollView {
        LazyVStack {
          ForEach(store.items, id: \.self) { asset in
            Text(asset)
          }
        }
      }
      .task {
        await store.requestAndLoad()
      }
    }
  }
}

#Preview {
    PhotosView()
}
