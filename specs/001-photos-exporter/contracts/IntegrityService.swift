// MARK: - Integrity Service Contract
// Handles checksums, verification, and audit operations

import Foundation
import CryptoKit

actor IntegrityServiceProtocol {
    // MARK: - Checksum Operations
    func calculateChecksum(data: Data, algorithm: ChecksumAlgorithm) async throws -> String
    func calculateChecksumForFile(url: URL, algorithm: ChecksumAlgorithm) async throws -> String
    func calculateChecksumStreaming(url: URL, algorithm: ChecksumAlgorithm, 
                                   chunkSize: Int, progressHandler: @escaping (Double) -> Void) async throws -> String
    
    // MARK: - Verification Operations
    func verifyIntegrity(localURL: URL, expectedChecksum: String, algorithm: ChecksumAlgorithm) async throws -> IntegrityResult
    func verifyRemoteIntegrity(adapter: ArchiveAdapter, path: String, 
                              expectedChecksum: String, algorithm: ChecksumAlgorithm) async throws -> IntegrityResult
    
    // MARK: - Batch Verification
    func verifyBatch(items: [VerificationItem], 
                    maxConcurrency: Int,
                    progressHandler: @escaping (VerificationProgress) -> Void) async throws -> [IntegrityResult]
    
    // MARK: - Archive Audit
    func auditArchive(archive: Archive, type: AuditType, 
                     progressHandler: @escaping (AuditProgress) -> Void) async throws -> AuditReport
    
    // MARK: - Repair Operations  
    func generateRepairPlan(auditReport: AuditReport) async throws -> RepairPlan
    func executeRepair(plan: RepairPlan, 
                      progressHandler: @escaping (RepairProgress) -> Void) async throws -> RepairResult
}

// MARK: - Supporting Types

struct VerificationItem: Sendable {
    let id: UUID
    let localURL: URL?
    let remotePath: String
    let expectedChecksum: String
    let algorithm: ChecksumAlgorithm
    let archiveAdapter: ArchiveAdapter
}

struct IntegrityResult: Sendable {
    let itemId: UUID
    let isValid: Bool
    let calculatedChecksum: String?
    let expectedChecksum: String
    let algorithm: ChecksumAlgorithm
    let verifiedAt: Date
    let error: Error?
    let verificationMethod: VerificationMethod
    
    enum VerificationMethod: String, CaseIterable {
        case localFile = "local_file"
        case remoteFile = "remote_file"
        case etag = "etag"
        case remoteChecksum = "remote_checksum"
    }
}

struct VerificationProgress: Sendable {
    let totalItems: Int
    let completedItems: Int
    let validItems: Int
    let invalidItems: Int
    let errorItems: Int
    let currentItem: String?
    let progress: Double
    let estimatedTimeRemaining: TimeInterval?
}

struct AuditReport: Sendable {
    let id: UUID
    let archiveId: UUID
    let auditType: AuditType
    let startedAt: Date
    let completedAt: Date?
    let status: AuditStatus
    
    // Results Summary
    let totalRecords: Int
    let verifiedRecords: Int
    let failedRecords: Int
    let missingRecords: Int
    let corruptedRecords: Int
    let extraFiles: Int
    
    // Detailed Issues
    let issues: [AuditIssue]
    let recommendations: [AuditRecommendation]
    
    // Statistics
    let totalDataSize: Int64
    let verifiedDataSize: Int64
    let corruptedDataSize: Int64
    let processingDuration: TimeInterval
    let averageVerificationRate: Double // Files per second
}

struct AuditIssue: Sendable, Identifiable {
    let id = UUID()
    let type: IssueType
    let severity: IssueSeverity  
    let recordId: UUID?
    let path: String
    let message: String
    let detectedAt: Date
    let metadata: [String: String]?
    
    enum IssueType: String, CaseIterable {
        case missing = "missing"
        case corrupted = "corrupted"
        case sizeError = "size_error"
        case accessDenied = "access_denied"
        case networkError = "network_error"
        case checksumMismatch = "checksum_mismatch"
        case unexpectedFile = "unexpected_file"
        case metadataError = "metadata_error"
    }
    
    enum IssueSeverity: String, CaseIterable {
        case low = "low"
        case medium = "medium" 
        case high = "high"
        case critical = "critical"
    }
}

struct AuditRecommendation: Sendable {
    let type: RecommendationType
    let title: String
    let description: String
    let affectedItems: Int
    let estimatedImpact: String
    let actionRequired: Bool
    
    enum RecommendationType: String, CaseIterable {
        case reexport = "reexport"
        case cleanup = "cleanup"
        case archiveRepair = "archive_repair"
        case configurationChange = "configuration_change"
        case spaceManagement = "space_management"
        case accessPermission = "access_permission"
    }
}

// MARK: - Repair Operations

struct RepairPlan: Sendable {
    let id = UUID()
    let auditReportId: UUID
    let createdAt = Date()
    let actions: [RepairAction]
    let estimatedDuration: TimeInterval
    let estimatedDataTransfer: Int64
    let riskLevel: RiskLevel
    
    enum RiskLevel: String, CaseIterable {
        case low = "low"         // Simple re-uploads, safe operations
        case medium = "medium"   // Multiple operations, some risk
        case high = "high"       // Destructive operations, backup recommended
    }
}

struct RepairAction: Sendable, Identifiable {
    let id = UUID()
    let type: ActionType
    let recordId: UUID?
    let sourcePath: String?
    let targetPath: String
    let description: String
    let priority: ActionPriority
    
    enum ActionType: String, CaseIterable {
        case reexport = "reexport"           // Re-export from Photos library
        case reupload = "reupload"           // Re-upload existing local file
        case deleteOrphan = "delete_orphan"  // Remove unexpected files
        case updateRecord = "update_record"  // Fix database record
        case skipEntry = "skip_entry"        // Mark as intentionally skipped
    }
    
    enum ActionPriority: String, CaseIterable {
        case low = "low"
        case normal = "normal"
        case high = "high"
        case urgent = "urgent"
    }
}

struct RepairProgress: Sendable {
    let planId: UUID
    let totalActions: Int
    let completedActions: Int
    let failedActions: Int
    let skippedActions: Int
    let currentAction: String?
    let progress: Double
    let estimatedTimeRemaining: TimeInterval?
}

struct RepairResult: Sendable {
    let planId: UUID
    let startedAt: Date
    let completedAt: Date
    let status: RepairStatus
    let successfulActions: Int
    let failedActions: Int
    let skippedActions: Int
    let errors: [RepairError]
    let summary: String
    
    enum RepairStatus: String, CaseIterable {
        case completed = "completed"
        case partiallyCompleted = "partially_completed"
        case failed = "failed"
        case cancelled = "cancelled"
    }
}

struct RepairError: Sendable {
    let actionId: UUID
    let type: ErrorType
    let message: String
    let isFatal: Bool
    let occurredAt: Date
    
    enum ErrorType: String, CaseIterable {
        case networkError = "network_error"
        case authenticationError = "authentication_error"
        case fileNotFound = "file_not_found"
        case insufficientSpace = "insufficient_space"
        case permissionDenied = "permission_denied"
        case corruptedSource = "corrupted_source"
        case unknownError = "unknown_error"
    }
}

// MARK: - Checksum Utilities

enum ChecksumAlgorithm: String, CaseIterable, Sendable {
    case sha256 = "sha256"
    case sha1 = "sha1"
    case md5 = "md5"
    
    var displayName: String {
        switch self {
        case .sha256: return "SHA-256"
        case .sha1: return "SHA-1"
        case .md5: return "MD5"
        }
    }
    
    var isSecure: Bool {
        switch self {
        case .sha256: return true
        case .sha1: return false
        case .md5: return false
        }
    }
}

// MARK: - Error Types

enum IntegrityServiceError: LocalizedError {
    case fileNotFound(String)
    case fileNotReadable(String)
    case checksumCalculationFailed(String)
    case verificationFailed(String)
    case auditAlreadyRunning(UUID)
    case auditNotFound(UUID)
    case repairPlanInvalid(String)
    case repairActionFailed(String)
    case unsupportedAlgorithm(String)
    case networkTimeoutDuringVerification(TimeInterval)
    case insufficientPermissions(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileNotReadable(let path):
            return "File not readable: \(path)"
        case .checksumCalculationFailed(let reason):
            return "Checksum calculation failed: \(reason)"
        case .verificationFailed(let reason):
            return "Verification failed: \(reason)"
        case .auditAlreadyRunning(let id):
            return "Audit already running: \(id)"
        case .auditNotFound(let id):
            return "Audit not found: \(id)"
        case .repairPlanInvalid(let reason):
            return "Repair plan invalid: \(reason)"
        case .repairActionFailed(let reason):
            return "Repair action failed: \(reason)"
        case .unsupportedAlgorithm(let algorithm):
            return "Unsupported checksum algorithm: \(algorithm)"
        case .networkTimeoutDuringVerification(let timeout):
            return "Network timeout during verification: \(timeout)s"
        case .insufficientPermissions(let operation):
            return "Insufficient permissions for: \(operation)"
        }
    }
}

// MARK: - Contract Tests

#if DEBUG
protocol IntegrityServiceTestProtocol {
    func testChecksumCalculation() async throws
    func testStreamingChecksum() async throws
    func testIntegrityVerification() async throws
    func testBatchVerification() async throws
    func testAuditOperations() async throws
    func testRepairOperations() async throws
    func testErrorHandling() async throws
    func testPerformanceUnderLoad() async throws
}
#endif