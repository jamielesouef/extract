//
//  ContentView.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftUI

struct AppContainerView: View {

  @State private var columnVisibility: NavigationSplitViewVisibility = .all

  @Environment(PhotosStore.self) var store
  @Environment(AppState.self) var appState

  var body: some View {
    Group {
      if let status = store.authorizationStatus {
        if status {
          photosViewForPlatform()
        } else {
          FailedPhotosAccessView()
        }
      }
    }
    .task {
      await store.requestAccess()
    }
    .padding()
  }

  @ViewBuilder
  private func photosViewForPlatform() -> some View {
#if os(macOS)
    SplitViewLayout
#else
    handleiOSViews()
#endif
  }

  @ViewBuilder
  private func handleiOSViews() -> some View {
    if UIDevice.current.userInterfaceIdiom == .pad {
      SplitViewLayout
    } else {
      iPhoneLayout
    }
  }

  @ViewBuilder
  private var SplitViewLayout: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      sidebar
        .frame(minWidth: 200)
    } detail: {
      PhotosView()
    }
  }

  @ViewBuilder
  private var iPhoneLayout: some View {

    @Bindable var state = appState

    NavigationStack(path: $state.pathStack) {
      PhotosView()
    }
  }

  @ViewBuilder
  private var sidebar: some View {
    List {
      NavigationLink("Item 1", value: "Item 1")
      NavigationLink("Item 2", value: "Item 2")
    }
    .navigationTitle("Sidebar")
  }
}

#Preview {
  AppContainerView()
}
