// MARK: - Archive Service Contract
// Manages archive configurations and storage backends

import Foundation

@MainActor
protocol ArchiveServiceProtocol: ObservableObject {
    // MARK: - Archive Management
    func createArchive(name: String, kind: ArchiveKind, configuration: any ArchiveConfiguration) async throws -> Archive
    func updateArchive(_ archive: Archive, configuration: any ArchiveConfiguration) async throws
    func deleteArchive(_ archive: Archive) async throws
    func testArchiveConnection(_ archive: Archive) async throws -> ArchiveConnectionStatus
    
    // MARK: - Archive Operations  
    func getAvailableSpace(_ archive: Archive) async throws -> Int64?
    func listContents(_ archive: Archive, path: String) async throws -> [StorageItem]
    func validatePath(_ archive: Archive, path: String) async throws -> Bool
    
    // MARK: - Audit Operations
    func startAudit(_ archive: Archive, type: AuditType) async throws -> AuditLog
    func getAuditProgress(_ auditId: UUID) -> AuditProgress?
    func getAuditHistory(_ archive: Archive) -> [AuditLog]
    
    // MARK: - Access Control
    var availableArchives: [Archive] { get }
    var activeArchives: [Archive] { get }
    
    func refreshArchiveStatus(_ archive: Archive) async throws
}

// MARK: - Storage Backend Contract

actor ArchiveAdapter {
    // MARK: - Connection Management
    func connect(configuration: any ArchiveConfiguration) async throws
    func disconnect() async
    func testConnection() async throws -> ArchiveConnectionStatus
    
    // MARK: - File Operations
    func upload(data: Data, to path: String, metadata: [String: String]?) async throws -> UploadResult
    func download(from path: String) async throws -> Data
    func delete(at path: String) async throws
    func move(from sourcePath: String, to destinationPath: String) async throws
    func copy(from sourcePath: String, to destinationPath: String) async throws
    
    // MARK: - Directory Operations
    func createDirectory(at path: String) async throws
    func listContents(at path: String, recursive: Bool) async throws -> [StorageItem]
    func deleteDirectory(at path: String, recursive: Bool) async throws
    
    // MARK: - Integrity Operations  
    func verifyChecksum(path: String, expectedChecksum: String, algorithm: ChecksumAlgorithm) async throws -> Bool
    func calculateChecksum(path: String, algorithm: ChecksumAlgorithm) async throws -> String
    
    // MARK: - Metadata Operations
    func getFileInfo(path: String) async throws -> FileInfo
    func setMetadata(path: String, metadata: [String: String]) async throws
    func getMetadata(path: String) async throws -> [String: String]
    
    // MARK: - Storage Information
    func getAvailableSpace() async throws -> Int64?
    func getUsedSpace() async throws -> Int64?
    func getTotalSpace() async throws -> Int64?
}

// MARK: - Supporting Types

struct ArchiveConnectionStatus {
    let isConnected: Bool
    let lastTestedAt: Date
    let responseTime: TimeInterval?
    let error: Error?
    let availableFeatures: [ArchiveFeature]
    
    enum ArchiveFeature: String, CaseIterable {
        case upload = "upload"
        case download = "download"
        case listing = "listing"
        case metadata = "metadata"
        case checksum = "checksum"
        case directoryCreation = "directory_creation"
        case moveOperations = "move_operations"
        case bulkOperations = "bulk_operations"
    }
}

struct UploadResult: Sendable {
    let path: String
    let size: Int64
    let checksum: String?
    let etag: String?
    let uploadedAt: Date
    let metadata: [String: String]?
}

struct StorageItem: Sendable {
    let name: String
    let path: String
    let size: Int64?
    let isDirectory: Bool
    let modifiedAt: Date?
    let checksum: String?
    let etag: String?
    let contentType: String?
}

struct FileInfo: Sendable {
    let path: String
    let size: Int64
    let isDirectory: Bool
    let createdAt: Date?
    let modifiedAt: Date?
    let checksum: String?
    let etag: String?
    let contentType: String?
    let permissions: FilePermissions?
}

struct FilePermissions: Sendable {
    let readable: Bool
    let writable: Bool
    let executable: Bool
}

struct AuditProgress {
    let auditId: UUID
    let totalItems: Int
    let processedItems: Int
    let verifiedItems: Int
    let failedItems: Int
    let missingItems: Int
    let corruptedItems: Int
    let currentPath: String?
    let progress: Double
    let status: AuditStatus
}

// MARK: - Error Types

enum ArchiveServiceError: LocalizedError {
    case archiveNotFound(UUID)
    case archiveAlreadyExists(String)
    case connectionFailed(String)
    case authenticationFailed(String)
    case pathNotFound(String)
    case pathAccessDenied(String)
    case insufficientSpace(Int64)
    case operationNotSupported(String)
    case networkTimeout(TimeInterval)
    case invalidConfiguration(String)
    case auditInProgress(UUID)
    
    var errorDescription: String? {
        switch self {
        case .archiveNotFound(let id):
            return "Archive not found: \(id)"
        case .archiveAlreadyExists(let name):
            return "Archive already exists: \(name)"
        case .connectionFailed(let details):
            return "Connection failed: \(details)"
        case .authenticationFailed(let details):
            return "Authentication failed: \(details)"
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .pathAccessDenied(let path):
            return "Access denied: \(path)"
        case .insufficientSpace(let needed):
            return "Insufficient space. Need: \(ByteCountFormatter.string(fromByteCount: needed, countStyle: .file))"
        case .operationNotSupported(let operation):
            return "Operation not supported: \(operation)"
        case .networkTimeout(let timeout):
            return "Network timeout after \(timeout) seconds"
        case .invalidConfiguration(let reason):
            return "Invalid configuration: \(reason)"
        case .auditInProgress(let auditId):
            return "Audit already in progress: \(auditId)"
        }
    }
}

// MARK: - Specific Archive Adapters

protocol FolderArchiveAdapter: ArchiveAdapter {
    func resolveSecurityScopedResource() async throws
    func createSecurityScopedBookmark() async throws -> Data
}

protocol NASArchiveAdapter: ArchiveAdapter {
    func establishPersistentConnection() async throws
    func handleConnectionDrop() async throws
    func testLatency() async throws -> TimeInterval
}

protocol S3ArchiveAdapter: ArchiveAdapter {
    func initiateMultipartUpload(key: String, metadata: [String: String]?) async throws -> String
    func uploadPart(uploadId: String, partNumber: Int, data: Data) async throws -> String
    func completeMultipartUpload(uploadId: String, parts: [S3Part]) async throws
    func abortMultipartUpload(uploadId: String) async throws
}

struct S3Part: Sendable {
    let partNumber: Int
    let etag: String
}

// MARK: - Contract Tests

#if DEBUG
protocol ArchiveServiceTestProtocol {
    func testArchiveCreation() async throws
    func testConnectionTesting() async throws
    func testFileOperations() async throws
    func testDirectoryOperations() async throws
    func testIntegrityOperations() async throws
    func testAuditOperations() async throws
    func testErrorHandling() async throws
}
#endif