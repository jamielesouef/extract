//
//  MediaStoreIntegrationTests.swift
//  extractTests
//
//  Created by Codex CLI.
//

@testable import extract
import Photos
import Testing

// Simple fake to drive authorization outcomes; tests the integration
// between MediaStore and its PhotoLibraryAuthorizing dependency.
struct FakeAuthorizer: PhotoLibraryAuthorizing {
  let status: PHAuthorizationStatus
  func requestAuthorization(for level: PHAccessLevel) async -> PHAuthorizationStatus { status }
}

@Suite("MediaStore Integration Tests")
struct MediaStoreIntegrationTests {
  @Test("requestAccess sets authorizationStatus true for .authorized")
  @MainActor
  func requestAccessAuthorized() async {
    let store = MediaStore(authorizer: FakeAuthorizer(status: .authorized))
    await store.requestAccess()
    #expect(store.authorizationStatus == true)
  }

  @Test("requestAccess sets authorizationStatus true for .limited")
  @MainActor
  func requestAccessLimited() async {
    let store = MediaStore(authorizer: FakeAuthorizer(status: .limited))
    await store.requestAccess()
    #expect(store.authorizationStatus == true)
  }

  @Test("requestAccess sets authorizationStatus false for denied-like statuses")
  @MainActor
  func requestAccessDeniedRestrictedNotDetermined() async {
    for s in [PHAuthorizationStatus.denied, .notDetermined, .restricted] {
      let store = MediaStore(authorizer: FakeAuthorizer(status: s))
      await store.requestAccess()
      #expect(store.authorizationStatus == false)
    }
  }
}

