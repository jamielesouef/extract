//
//  AppContainerView.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftUI

struct AppContainerView: View {
  @State private var preferredColumn: NavigationSplitViewColumn = .detail

  @Environment(MediaStore.self) var store
  @Environment(AppState.self) var appState

  var body: some View {
    @Bindable var appState = appState

    NavigationSplitView(preferredCompactColumn: $preferredColumn) {
      sidebar
        .frame(minWidth: 200)
        .navigationDestination(for: NavigationOptions.self) { page in
          NavigationStack(path: $appState.path) {
            page.viewForPage()
          }
        }
    } detail: {
      NavigationStack(path: $appState.path) {
        if let status = store.authorizationStatus, status {
          PhotosView()
        } else {
          FailedPhotosAccessView()
        }
      }

      .task {
        await store.requestAccess()
      }
      .padding()
    }
  }

  @ViewBuilder
  private var sidebar: some View {
    Section {
      ForEach(NavigationOptions.pages) { page in
        NavigationLink(value: page) {
          Label(page.name, systemImage: page.icon)
        }
      }
    }
    .navigationTitle("Sidebar")
  }
}

#Preview {
  AppContainerView()
}
