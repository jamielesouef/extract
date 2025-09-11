//
//  extractApp.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftData
import SwiftUI

@main
struct ExtractApp: App {
  @State private var appState = AppState()
  @State private var photoStore = MediaStore()

  @State private var modelContainer: ModelContainer = {
    let scheme = Schema([MediaItem.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
      return try ModelContainer(for: scheme, configurations: config)
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
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
