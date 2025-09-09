// MARK: - Selection Service Contract

// Manages photo selection state and operations

import Foundation

@MainActor
protocol SelectionServiceProtocol: ObservableObject {
  // MARK: - Selection State

  var selectedPhotoIds: Set<String> { get }
  var isSelectionMode: Bool { get }
  var selectedCount: Int { get }

  // MARK: - Selection Operations

  func enterSelectionMode()
  func exitSelectionMode()
  func toggleSelection(for photoId: String)
  func select(_ photoId: String)
  func deselect(_ photoId: String)
  func selectAll(_ photoIds: [String])
  func clearSelection()

  // MARK: - Selection Queries

  func isSelected(_ photoId: String) -> Bool
  func canSelectAll(totalCount: Int) -> Bool
  func hasSelection() -> Bool

  // MARK: - Batch Operations

  func selectPhotos(_ photoIds: [String])
  func deselectPhotos(_ photoIds: [String])
  func selectRange(from startId: String, to endId: String, in photoIds: [String])
}

// MARK: - Supporting Types

struct SelectionChange {
  let photoId: String
  let isSelected: Bool
  let timestamp: Date

  init(photoId: String, isSelected: Bool) {
    self.photoId = photoId
    self.isSelected = isSelected
    timestamp = Date()
  }
}

struct SelectionMetrics {
  let totalSelections: Int
  let selectionTime: TimeInterval
  let averageSelectionLatency: TimeInterval

  init() {
    totalSelections = 0
    selectionTime = 0
    averageSelectionLatency = 0
  }
}

// MARK: - Selection Events

enum SelectionEvent {
  case enteredSelectionMode
  case exitedSelectionMode
  case photoSelected(String)
  case photoDeselected(String)
  case allSelected(count: Int)
  case selectionCleared
  case batchSelected([String])
  case batchDeselected([String])
}

// MARK: - Error Types

enum SelectionError: LocalizedError {
  case photoNotFound(String)
  case selectionLimitExceeded(Int)
  case invalidSelection(String)
  case selectionModeRequired

  var errorDescription: String? {
    switch self {
    case let .photoNotFound(id):
      return "Photo not found: \(id)"
    case let .selectionLimitExceeded(limit):
      return "Selection limit exceeded. Maximum: \(limit)"
    case let .invalidSelection(reason):
      return "Invalid selection: \(reason)"
    case .selectionModeRequired:
      return "Selection mode must be active for this operation"
    }
  }
}

// MARK: - Configuration

struct SelectionConfiguration {
  let maxSelections: Int? // nil for unlimited
  let allowMultipleSelection: Bool
  let persistSelectionOnExit: Bool
  let selectionFeedbackStyle: SelectionFeedbackStyle

  static let `default` = SelectionConfiguration(
    maxSelections: nil,
    allowMultipleSelection: true,
    persistSelectionOnExit: false,
    selectionFeedbackStyle: .checkmark
  )

  static let limited = SelectionConfiguration(
    maxSelections: 100,
    allowMultipleSelection: true,
    persistSelectionOnExit: false,
    selectionFeedbackStyle: .checkmark
  )
}

enum SelectionFeedbackStyle {
  case checkmark
  case highlight
  case border
  case overlay
}

// MARK: - Contract Tests

#if DEBUG
  protocol SelectionServiceTestProtocol {
    func testSelectionModeToggle() async throws
    func testSingleSelection() async throws
    func testMultipleSelection() async throws
    func testSelectAll() async throws
    func testClearSelection() async throws
    func testSelectionLimits() async throws
    func testBatchOperations() async throws
    func testSelectionPersistence() async throws
    func testErrorHandling() async throws
  }
#endif
