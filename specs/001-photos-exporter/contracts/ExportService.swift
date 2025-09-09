// MARK: - Export Service Contract
// Orchestrates export jobs and manages transfer operations

import Foundation

@MainActor
protocol ExportServiceProtocol: ObservableObject {
    // MARK: - Job Management
    func createJob(name: String, 
                  archive: Archive, 
                  selection: SelectionSpec, 
                  options: ExportOptions) async throws -> ExportJob
    
    func startJob(_ job: ExportJob) async throws
    func pauseJob(_ job: ExportJob) async throws
    func cancelJob(_ job: ExportJob) async throws
    func retryJob(_ job: ExportJob) async throws
    func deleteJob(_ job: ExportJob) async throws
    
    // MARK: - Queue Management
    var activeJobs: [ExportJob] { get }
    var queuedJobs: [ExportJob] { get }
    var completedJobs: [ExportJob] { get }
    
    func getJobProgress(_ jobId: UUID) -> ExportProgress?
    func getJobLogs(_ jobId: UUID) -> [ExportLogEntry]
    
    // MARK: - Batch Operations
    func pauseAllJobs() async throws
    func resumeAllJobs() async throws
    func clearCompletedJobs() async throws
}

// MARK: - Supporting Types

struct ExportProgress {
    let jobId: UUID
    let totalItems: Int
    let completedItems: Int
    let failedItems: Int
    let skippedItems: Int
    let currentItem: String?
    let overallProgress: Double
    let bytesTransferred: Int64
    let totalBytes: Int64
    let transferRate: Double // Bytes per second
    let estimatedTimeRemaining: TimeInterval?
    let status: JobStatus
}

struct ExportLogEntry {
    let id: UUID
    let jobId: UUID
    let timestamp: Date
    let level: LogLevel
    let message: String
    let itemIdentifier: String?
    let error: Error?
    
    enum LogLevel: String, CaseIterable {
        case debug = "debug"
        case info = "info" 
        case warning = "warning"
        case error = "error"
    }
}

// MARK: - Error Types

enum ExportServiceError: LocalizedError {
    case jobNotFound(UUID)
    case jobAlreadyRunning(UUID)
    case jobNotRunning(UUID)
    case archiveUnavailable(String)
    case insufficientSpace(Int64) // Required bytes
    case concurrencyLimitExceeded(Int)
    case invalidSelection(String)
    case configurationInvalid(String)
    
    var errorDescription: String? {
        switch self {
        case .jobNotFound(let id):
            return "Export job not found: \(id)"
        case .jobAlreadyRunning(let id):
            return "Export job is already running: \(id)"
        case .jobNotRunning(let id):
            return "Export job is not currently running: \(id)"
        case .archiveUnavailable(let name):
            return "Archive '\(name)' is not available"
        case .insufficientSpace(let required):
            return "Insufficient space. Required: \(ByteCountFormatter.string(fromByteCount: required, countStyle: .file))"
        case .concurrencyLimitExceeded(let limit):
            return "Cannot start job. Maximum concurrent jobs: \(limit)"
        case .invalidSelection(let reason):
            return "Invalid photo selection: \(reason)"
        case .configurationInvalid(let reason):
            return "Invalid export configuration: \(reason)"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let exportJobStarted = Notification.Name("exportJobStarted")
    static let exportJobCompleted = Notification.Name("exportJobCompleted")
    static let exportJobFailed = Notification.Name("exportJobFailed")
    static let exportJobPaused = Notification.Name("exportJobPaused")
    static let exportJobCancelled = Notification.Name("exportJobCancelled")
    static let exportProgressUpdated = Notification.Name("exportProgressUpdated")
}

// MARK: - Contract Tests

#if DEBUG
protocol ExportServiceTestProtocol {
    func testJobCreation() async throws
    func testJobExecution() async throws  
    func testJobPauseResume() async throws
    func testJobCancellation() async throws
    func testConcurrencyLimits() async throws
    func testProgressReporting() async throws
    func testErrorHandling() async throws
}
#endif