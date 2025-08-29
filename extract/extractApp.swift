//
//  extractApp.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftUI
import SwiftData

@main
struct extractApp: App {
  
  @State private var appState = AppState()
  @State private var photoStore = PhotosStore()
  
  @State private var modelContainer: ModelContainer = {
    let scheme = Schema([MediaItem.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: scheme, configurations: config)
  }()

  var body: some Scene {
    WindowGroup {
      ExtractSplitView()
        .environment(appState)
        .environment(photoStore)
        .modelContainer(modelContainer)
        .onGeometryChange(for: CGSize.self) { geometry in
          geometry.size
        } action: { newValue in
          appState.windowSize = newValue
        }
    }
  }
}
