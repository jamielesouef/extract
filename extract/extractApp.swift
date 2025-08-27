//
//  extractApp.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftUI

@main
struct extractApp: App {
  
  @State private var appState = AppState()
  @State private var photoStore = PhotosStore()

  var body: some Scene {
    WindowGroup {
      ExtractSplitView()
        .environment(appState)
        .environment(photoStore)
        .onGeometryChange(for: CGSize.self) { geometry in
          geometry.size
        } action: { newValue in
          appState.windowSize = newValue
        }
    }
  }
}
