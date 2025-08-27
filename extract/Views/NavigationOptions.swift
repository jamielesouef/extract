//
//  NavigationOptions.swift
//  extract
//
//  Created by Jamie Le Souef on 27/8/2025.
//


import SwiftUI

enum NavigationOptions: Equatable, Hashable, Identifiable {
  case newPhotos
  case backedUpPhotos
  case failedPhotosAccess
  
  var id: String {
    switch self {
    case .newPhotos:
      "newPhotos"
    case .backedUpPhotos:
      "backedupPhotos"
    case .failedPhotosAccess:
      "failedPhotosAccess"
    }
  }
  
  static let pages: [NavigationOptions] = [.newPhotos, .backedUpPhotos]
  
  var name: LocalizedStringResource {
    switch self {
    case .newPhotos:
      LocalizedStringResource("New Photos", comment: "New photos to be backed up")
    case .backedUpPhotos:
      LocalizedStringResource("Backed up Photos", comment: "All photos that are in a backup location")
    case .failedPhotosAccess:
      LocalizedStringResource("Photos Access Required", comment: "Indicates that the app needs access to photos")
    }
  }
  
  var icon: String {
    switch self {
    case .newPhotos:
      "photo.circle"
    case .backedUpPhotos:
      "lock.circle"
    case .failedPhotosAccess:
      "exclamationmark.triangle"
    }
  }
  
  @MainActor @ViewBuilder func viewForPage() -> some View {
    switch self {
    case .newPhotos:
      PhotosView()
    case .backedUpPhotos:
      BackupsView()
    case .failedPhotosAccess:
      FailedPhotosAccessView()
    }
  }
}
