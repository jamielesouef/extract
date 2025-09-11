# Photos Exporter Data Model

## Core Entities

### Archive
Represents a configured destination for photo exports (local folder, NAS, S3).

```swift
@Model
final class Archive {
    @Attribute(.unique) var id: UUID
    var name: String                    // User-friendly name
    var kind: ArchiveKind              // .folder, .nas, .s3
    var configJSON: Data               // Backend-specific configuration
    var createdAt: Date
    var updatedAt: Date
    var lastConnectedAt: Date?         // Last successful connection test
    var isActive: Bool                 // Whether archive is available for use
    
    // Relationships
    var jobs: [ExportJob] = []
    var records: [ArchiveRecord] = []
}

enum ArchiveKind: String, Codable, CaseIterable {
    case folder = "folder"            // Local/external folder
    case nas = "nas"                  // Network-attached storage
    case s3 = "s3"                    // S3-compatible storage
}
```

### Archive Configuration Structures

```swift
// Stored as JSON in Archive.configJSON
protocol ArchiveConfiguration: Codable {
    var displayName: String { get }
    func validate() throws
}

struct FolderConfiguration: ArchiveConfiguration {
    let displayName: String
    let bookmarkData: Data            // Security-scoped bookmark
    let path: String                  // Human-readable path
    let supportedTypes: [String]      // UTType identifiers
}

struct NASConfiguration: ArchiveConfiguration {
    let displayName: String
    let serverURL: String             // smb://server/share or https://webdav
    let username: String
    let port: Int?
    let protocol: NASProtocol         // .smb, .webdav, .nfs
    
    enum NASProtocol: String, Codable {
        case smb = "smb"
        case webdav = "webdav"
        case nfs = "nfs"
    }
}

struct S3Configuration: ArchiveConfiguration {
    let displayName: String
    let bucketName: String
    let region: String
    let endpoint: String?             // For non-AWS S3-compatible services
    let accessKeyId: String
    let useSSE: Bool                  // Server-side encryption
    let storageClass: String?         // STANDARD, IA, GLACIER, etc.
    let pathPrefix: String?           // Optional path prefix in bucket
}
```

### ExportJob
Represents a batch export operation with metadata and progress tracking.

```swift
@Model
final class ExportJob {
    @Attribute(.unique) var id: UUID
    var name: String                  // User-provided job name
    var createdAt: Date
    var startedAt: Date?
    var finishedAt: Date?
    var status: JobStatus
    var priority: JobPriority
    
    // Configuration
    var selectionSpecJSON: Data       // How assets were selected
    var optionsJSON: Data             // Export options (naming, verification, etc.)
    
    // Progress tracking
    var totalItems: Int = 0
    var completedItems: Int = 0
    var failedItems: Int = 0
    var totalBytes: Int64 = 0
    var transferredBytes: Int64 = 0
    var estimatedRemainingSeconds: Int?
    
    // Error tracking
    var lastErrorMessage: String?
    var retryCount: Int = 0
    var maxRetries: Int = 3
    
    // Relationships
    var archive: Archive
    var items: [ExportItem] = []
    
    // Computed properties
    var progress: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(completedItems) / Double(totalItems)
    }
    
    var isRunning: Bool {
        status == .running
    }
    
    var canRetry: Bool {
        status == .failed && retryCount < maxRetries
    }
}

enum JobStatus: String, Codable, CaseIterable {
    case queued = "queued"           // Waiting to start
    case running = "running"         // Currently executing
    case paused = "paused"           // User paused
    case completed = "completed"     // All items processed successfully
    case failed = "failed"           // Job failed (may be retryable)
    case cancelled = "cancelled"     // User cancelled
    case partiallyCompleted = "partially_completed" // Some items failed
}

enum JobPriority: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"
}
```

### Selection and Options Structures

```swift
// Stored as JSON in ExportJob.selectionSpecJSON
struct SelectionSpec: Codable {
    let type: SelectionType
    let parameters: [String: String]  // Flexible key-value parameters
    let assetIdentifiers: [String]?   // Explicit asset IDs (for manual selection)
    let albumIdentifier: String?      // Album-based selection
    let smartFilters: SmartFilters?   // Filter-based selection
    
    enum SelectionType: String, Codable {
        case explicit = "explicit"    // Manually selected assets
        case album = "album"         // All assets from specific album
        case smartFilter = "smart_filter" // Filter-based selection
        case allPhotos = "all_photos" // All photos in library
    }
}

struct SmartFilters: Codable {
    let mediaTypes: [MediaType]?      // Photo, video, etc.
    let dateRange: DateRange?
    let includeEdited: Bool?
    let includeRAW: Bool?
    let includeLivePhotos: Bool?
    let includeBurst: Bool?
    let includeScreenshots: Bool?
    let favoritesOnly: Bool?
    
    enum MediaType: String, Codable {
        case photo = "photo"
        case video = "video"
        case livePhoto = "live_photo"
        case raw = "raw"
        case screenshot = "screenshot"
    }
}

struct DateRange: Codable {
    let startDate: Date
    let endDate: Date
}

// Stored as JSON in ExportJob.optionsJSON
struct ExportOptions: Codable {
    let includeOriginals: Bool = true
    let includeEdited: Bool = false
    let includeLivePhotoVideo: Bool = true
    let includeMetadataSidecars: Bool = false
    let sidecarFormat: SidecarFormat = .json
    
    // Naming and organization
    let folderStructure: FolderStructure = .dateHierarchy
    let namingPattern: String = "{original_filename}"
    let conflictResolution: ConflictResolution = .skip
    
    // Verification
    let verificationLevel: VerificationLevel = .checksum
    let checksumAlgorithm: ChecksumAlgorithm = .sha256
    
    // Network constraints
    let allowCellular: Bool = false
    let requirePower: Bool = false
    let maxConcurrentTransfers: Int = 3
    let bandwidthLimit: Int64? = nil  // Bytes per second limit
    
    enum SidecarFormat: String, Codable {
        case xmp = "xmp"
        case json = "json"
        case both = "both"
    }
    
    enum FolderStructure: String, Codable {
        case flat = "flat"                    // All files in root
        case dateHierarchy = "date_hierarchy" // YYYY/MM/DD/
        case albumHierarchy = "album_hierarchy" // Album/Subfolder/
        case custom = "custom"                // User-defined pattern
    }
    
    enum ConflictResolution: String, Codable {
        case skip = "skip"                    // Skip existing files
        case overwrite = "overwrite"          // Always overwrite
        case overwriteIfDifferent = "overwrite_if_different" // Compare checksums
        case rename = "rename"                // Append suffix to filename
    }
    
    enum VerificationLevel: String, Codable {
        case none = "none"                    // No verification
        case size = "size"                    // File size only
        case checksum = "checksum"            // Full checksum verification
    }
    
    enum ChecksumAlgorithm: String, Codable {
        case sha256 = "sha256"
        case md5 = "md5"
    }
}
```

### ExportItem
Represents an individual media item within an export job.

```swift
@Model
final class ExportItem {
    @Attribute(.unique) var id: UUID
    var localIdentifier: String       // PHAsset localIdentifier
    var originalFilename: String
    var exportFilename: String        // Final filename after naming rules
    var exportPath: String            // Full path in archive
    
    // Metadata
    var mediaType: MediaType          // photo, video, etc.
    var fileExtension: String         // Original file extension
    var byteSize: Int64              // Original file size
    var creationDate: Date?          // Asset creation date
    var modificationDate: Date?      // Asset modification date
    
    // Export state
    var state: ItemState
    var startedAt: Date?
    var completedAt: Date?
    var transferredBytes: Int64 = 0
    var checksum: String?            // Computed checksum
    var remoteChecksum: String?      // Remote storage checksum (ETag, etc.)
    
    // Error tracking
    var errorMessage: String?
    var retryCount: Int = 0
    var lastAttemptAt: Date?
    
    // Relationships
    var job: ExportJob
    
    // Computed properties
    var progress: Double {
        guard byteSize > 0 else { return 0.0 }
        return Double(transferredBytes) / Double(byteSize)
    }
    
    var isCompleted: Bool {
        state == .completed
    }
    
    var canRetry: Bool {
        state == .failed && retryCount < job.maxRetries
    }
}

enum ItemState: String, Codable, CaseIterable {
    case pending = "pending"          // Not started
    case processing = "processing"    // Loading from Photos library
    case transferring = "transferring" // Uploading to archive
    case verifying = "verifying"      // Checking integrity
    case completed = "completed"      // Successfully exported
    case skipped = "skipped"          // Skipped due to conflict rules
    case failed = "failed"            // Failed (may be retryable)
    case cancelled = "cancelled"      // Cancelled by user/system
}

enum MediaType: String, Codable, CaseIterable {
    case photo = "photo"
    case video = "video"
    case livePhoto = "live_photo"
    case rawPhoto = "raw_photo"
    case screenshot = "screenshot"
    case panorama = "panorama"
    case burst = "burst"
    case timelapse = "timelapse"
    case slowMotion = "slow_motion"
    case portraitPhoto = "portrait_photo"
    case depthPhoto = "depth_photo"
    case unknown = "unknown"
}
```

### ArchiveRecord
Maintains a record of all items successfully exported to each archive for audit purposes.

```swift
@Model
final class ArchiveRecord {
    @Attribute(.unique) var id: UUID
    var localIdentifier: String       // PHAsset localIdentifier
    var exportPath: String            // Path in archive
    var originalFilename: String
    var exportFilename: String
    
    // File metadata
    var byteSize: Int64
    var checksum: String
    var checksumAlgorithm: ChecksumAlgorithm
    var mediaType: MediaType
    var creationDate: Date?           // Asset creation date
    
    // Export metadata
    var exportedAt: Date              // When export completed
    var exportJobId: UUID             // Reference to originating job
    var lastVerifiedAt: Date?         // Last integrity check
    var verificationStatus: VerificationStatus?
    
    // Archive information
    var archiveSnapshot: String       // JSON snapshot of archive config at time of export
    
    // Relationships
    var archive: Archive
    
    enum VerificationStatus: String, Codable {
        case verified = "verified"     // Integrity check passed
        case failed = "failed"         // Integrity check failed
        case missing = "missing"       // File not found in archive
        case corrupted = "corrupted"   // File exists but checksum mismatch
    }
}
```

### AuditLog
Tracks audit operations and their results for integrity monitoring.

```swift
@Model
final class AuditLog {
    @Attribute(.unique) var id: UUID
    var archiveId: UUID
    var startedAt: Date
    var completedAt: Date?
    var status: AuditStatus
    
    // Results
    var totalRecords: Int = 0
    var verifiedRecords: Int = 0
    var failedRecords: Int = 0
    var missingRecords: Int = 0
    var corruptedRecords: Int = 0
    
    // Configuration
    var auditType: AuditType
    var verificationLevel: VerificationLevel
    
    // Error tracking
    var errorMessage: String?
    var issues: [AuditIssue] = []
    
    enum AuditStatus: String, Codable {
        case running = "running"
        case completed = "completed"
        case failed = "failed"
        case cancelled = "cancelled"
    }
    
    enum AuditType: String, Codable {
        case full = "full"             // All records in archive
        case incremental = "incremental" // Only recent exports
        case targeted = "targeted"     // Specific files/folders
    }
}

struct AuditIssue: Codable {
    let recordId: UUID
    let type: IssueType
    let message: String
    let path: String
    let detectedAt: Date
    
    enum IssueType: String, Codable {
        case missing = "missing"
        case corrupted = "corrupted"
        case accessDenied = "access_denied"
        case networkError = "network_error"
        case sizeError = "size_error"
    }
}
```

## Entity Relationships

```
Archive (1) ──── (∞) ExportJob
Archive (1) ──── (∞) ArchiveRecord

ExportJob (1) ──── (∞) ExportItem

Archive (1) ──── (∞) AuditLog
```

## State Transitions

### ExportJob Status Flow
```
queued → running → [completed | failed | cancelled | partiallyCompleted]
        ↓
      paused → running
        ↓
    cancelled
```

### ExportItem State Flow  
```
pending → processing → transferring → verifying → completed
         ↓             ↓             ↓
       failed ←──────failed ←──────failed
         ↓
       skipped
```

## Validation Rules

1. **Archive Uniqueness**: Archive names must be unique within the user's configuration
2. **Job Dependencies**: ExportJob cannot be deleted while status is `running` or `queued`
3. **Configuration Integrity**: Archive configuration JSON must be valid for its `ArchiveKind`
4. **Checksum Consistency**: All `ArchiveRecord` entries must have valid checksums when verification is enabled
5. **State Consistency**: ExportItem state must align with parent ExportJob status
6. **Identifier Validity**: All `localIdentifier` values must correspond to valid PHAssets (validated at job creation)

## Indexes

Performance-critical queries require proper indexing:

```swift
// Compound indexes for common queries
@Model
final class ExportJob {
    @Index([\.status, \.createdAt])    // Active jobs by date
    @Index([\.archive.id, \.status])   // Jobs per archive
    // ... other properties
}

@Model  
final class ExportItem {
    @Index([\.job.id, \.state])        // Items per job by state
    @Index([\.localIdentifier])        // Asset lookup
    // ... other properties
}

@Model
final class ArchiveRecord {
    @Index([\.archive.id, \.exportedAt]) // Records per archive by date
    @Index([\.localIdentifier])          // Duplicate detection
    @Index([\.checksum])                  // Integrity queries
    // ... other properties  
}
```

This data model supports the complete Photos Exporter feature set with proper relationships, state management, and audit capabilities while maintaining SwiftData best practices and performance considerations.