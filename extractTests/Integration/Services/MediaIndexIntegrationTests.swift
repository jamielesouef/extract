//
//  MediaIndexIntegrationTests.swift
//  extractTests
//
//  Created by Codex CLI.
//

@testable import extract
import SwiftData
import Testing

@Suite("MediaIndex Integration Tests")
struct MediaIndexIntegrationTests {
  @Test("Persists across MediaIndex instances with same container")
  func persistsAcrossInstances() async throws {
    let schema = Schema([MediaItem.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: config)

    let indexA = await MediaIndex(modelContainer: container)
    try await indexA.addMedia(media: [
      MediaItemData(mediaId: "persist-1", kind: .image, status: .unknown, filename: nil),
      MediaItemData(mediaId: "persist-2", kind: .video, status: .notBackedUp, filename: nil),
    ])

    // New actor instance sharing the same container should see the same data
    _ = await MediaIndex(modelContainer: container)

    let descriptor = FetchDescriptor<MediaItem>()
    let context = ModelContext(container)
    let savedItems = try context.fetch(descriptor)

    #expect(savedItems.count == 2)
    let ids = Set(savedItems.map { $0.mediaId })
    #expect(ids.contains("persist-1"))
    #expect(ids.contains("persist-2"))
  }
}
