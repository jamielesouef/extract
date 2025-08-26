//
//  ContentView.swift
//  extract
//
//  Created by Jamie Le Souef on 25/8/2025.
//

import SwiftUI

struct AppContainerView: View {

  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

  @Environment(PhotosStore.self) var store

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      if let authorizationStatus = store.authorizationStatus {
        if authorizationStatus {
          Text("Awesome")
        } else {
          FailedPhotosAccessView()
        }
      }
    } detail: {
      Text("Content")
    }
    .task {
      await store.requestAccess()
    }
    .padding()
  }
}

#Preview {
  AppContainerView()
}
