# Photos Exporter Research

## Swift 6 Concurrency Architecture

### Decision: Actor-Based Isolation Pattern
**Rationale**: Swift 6's strict concurrency requires careful isolation between UI, data, and I/O operations. Actor-based isolation provides thread-safe access to shared resources while maintaining performance for concurrent operations.

**Key Patterns**:
- `@MainActor` for UI and PhotoLibrary observers  
- `@ModelActor` for SwiftData operations
- Custom actors for file I/O (`FileExportManager`) and network (`NetworkUploadManager`)
- `Task.detached` for PhotoKit operations to avoid main actor isolation

**Alternatives Considered**: 
- Traditional GCD approach - rejected due to Swift 6 data race detection
- Single-actor design - rejected due to performance bottlenecks for I/O operations

## PhotoKit Integration

### Decision: Resource Request with Structured Concurrency
**Rationale**: PhotoKit's original resource requests can be expensive and require careful memory management. Using TaskGroup for concurrent requests with proper cancellation support.

**Key Patterns**:
- `PHImageRequestOptions.isNetworkAccessAllowed = true` for iCloud downloads
- Chunked processing with `withTaskGroup` for concurrent asset handling
- Progress reporting via `progressHandler` callback to main actor
- Memory management using `PHCachingImageManager` for preloading

**Alternatives Considered**:
- Serial processing - rejected due to performance requirements (80+ MB/s target)
- Direct `PHAsset.requestContentEditingInput` - rejected due to sandbox limitations

## Archive Storage Architecture

### Decision: Protocol-Based Adapter Pattern
**Rationale**: Multiple storage backends (local, NAS, S3) require unified interface while allowing backend-specific optimizations.

**Implementation**:
```swift
protocol ArchiveAdapter: Actor {
    func upload(data: Data, to path: String, progress: @escaping (Double) -> Void) async throws -> UploadResult
    func verify(path: String, checksum: String) async throws -> Bool
    func testConnection() async throws -> Bool
}
```

**Storage Backends**:
1. **FolderArchiveAdapter**: Direct file system access with security-scoped bookmarks
2. **NASArchiveAdapter**: SMB/WebDAV using FileProvider framework
3. **S3ArchiveAdapter**: AWS SDK with multipart upload support

**Alternatives Considered**:
- Single storage type - rejected due to user requirements for multiple destinations
- Direct HTTP implementation for S3 - rejected in favor of AWS SDK for robustness

## NAS Integration Strategy

### Decision: FileProvider Framework with Fallback
**Rationale**: iOS sandbox restrictions require user-driven authentication. FileProvider framework provides comprehensive SMB/WebDAV support.

**Implementation**:
- **Primary**: FileProvider by amosavian for SMB2/3, WebDAV
- **Authentication**: Security-scoped bookmarks for persistent access
- **Error Handling**: Automatic retry with exponential backoff for network issues
- **macOS**: `NSOpenPanel` for initial folder selection, bookmark persistence

**Alternatives Considered**:
- Native SMB mounting - rejected due to iOS sandbox limitations
- Direct protocol implementation - rejected due to complexity and maintenance overhead

## S3 Integration Strategy

### Decision: AWS SDK with Custom Endpoint Support
**Rationale**: AWS SDK provides robust multipart upload, error handling, and retry logic. Custom endpoint support enables MinIO and other S3-compatible services.

**Key Features**:
- Multipart upload for files > 5MB (required for large photos/videos)
- Concurrent part uploads with semaphore-based throttling (max 3 concurrent)
- ETag validation for integrity verification
- Custom endpoint configuration for non-AWS providers

**Authentication Options**:
- Static credentials (access key/secret) stored in Keychain
- IAM roles (macOS only, where supported)

**Alternatives Considered**:
- Custom HTTP implementation - rejected due to AWS SDK's superior error handling
- Single-part uploads only - rejected due to performance and reliability concerns

## SwiftData Concurrency

### Decision: ModelActor with PersistentIdentifier Transfer
**Rationale**: SwiftData models are not Sendable, but PersistentIdentifiers are. Using ModelActor isolation prevents data races while enabling concurrent operations.

**Pattern**:
```swift
@ModelActor
actor DataStore {
    func saveExportProgress(_ progress: ExportProgress) throws {
        modelContext.insert(progress)
        try modelContext.save()
    }
}
```

**Data Transfer**: Use `PersistentIdentifier` to transfer model references between actors/tasks.

**Alternatives Considered**:
- CoreData - rejected in favor of SwiftData for modern Swift integration
- Direct model passing - rejected due to Sendable requirements

## Background Processing Strategy

### Decision: BGProcessingTask with Checkpoint Pattern
**Rationale**: iOS background execution requires careful state management and progress checkpointing for app termination scenarios.

**Implementation**:
- Register `BGProcessingTask` with network and power requirements
- Checkpoint export progress every 10 items or 2 minutes
- Graceful cancellation with `task.expirationHandler`
- Resume capability using persisted job state

**macOS Considerations**:
- User-initiated long-running tasks (no BGProcessingTask needed)
- Handle sleep/wake events and external drive disconnection

**Alternatives Considered**:
- Foreground-only processing - rejected due to user experience requirements
- Silent push notifications - rejected due to reliability and user control concerns

## Integrity Verification

### Decision: SHA-256 with Streaming Computation
**Rationale**: Large media files require memory-efficient checksum computation. SHA-256 provides strong integrity guarantees.

**Implementation**:
- Stream-based hashing during file I/O to avoid double reads
- Chunked processing (1MB chunks) for memory efficiency
- Store checksums in SwiftData for audit capability
- S3: Compare with ETag when available, handle multipart ETags

**Alternatives Considered**:
- MD5 checksums - rejected due to security concerns
- File size only - rejected due to insufficient integrity guarantees
- CRC32 - rejected due to collision probability with large file sets

## Performance Optimization

### Decision: Adaptive Concurrency with Thermal Management
**Rationale**: Target 80+ MB/s throughput requires careful concurrency management while respecting device thermal limits.

**Strategies**:
- Bounded task groups with configurable concurrency limits
- Thermal state monitoring to reduce concurrency when device is hot
- Back-pressure mechanisms for network-bound operations
- Memory management via chunked processing and caching strategies

**Monitoring**:
- Real-time throughput measurement
- Progress reporting with ETA calculation
- Error categorization and retry logic

**Alternatives Considered**:
- Fixed concurrency limits - rejected due to varying device capabilities
- Unlimited concurrency - rejected due to resource exhaustion risks
- Single-threaded processing - rejected due to performance requirements

## Testing Strategy

### Decision: Protocol-Based Testing with Real Dependencies
**Rationale**: Archive adapters require integration testing with actual storage systems. Protocol-based design enables test doubles while maintaining real dependency testing.

**Test Types**:
1. **Unit Tests**: File naming patterns, checksum validation, error handling
2. **Contract Tests**: Archive adapter protocol compliance
3. **Integration Tests**: Real S3/NAS connections with test credentials
4. **Performance Tests**: Throughput measurement and concurrency stress testing

**Test Infrastructure**:
- Mock S3 server (MinIO) for integration testing
- Test SMB share for NAS testing
- Synthetic photo library for large-scale testing
- Memory and performance profiling integration

**Alternatives Considered**:
- Mock-only testing - rejected due to network integration complexity
- Manual testing only - rejected due to reliability requirements
- Simplified test scenarios - rejected due to real-world usage patterns