# Photos Exporter – Product & Technical Spec (v0.1)

*Last updated: 9 September 2025 (AET)*

## 1. Overview

Photos Exporter is a privacy‑respecting, cross‑platform Apple app (iOS 26, iPadOS 26, macOS 26) that lets users browse their Photos library and create **export jobs** to download the **original, full‑resolution** assets from iCloud and write them into one or more **Archives** (destinations). Archives can target:

- Local folders (device storage, external drive on macOS)
- Network shares (NAS via SMB/NFS/WebDAV)
- Object storage (S3‑compatible)

Each Archive maintains a verifiable **consistency record** to ensure parity between iCloud originals and the archived copies over time.

### Goals

- One‑click export of "originals" with optional metadata sidecars.
- Resumable, fault‑tolerant jobs that can run in background where allowed.
- Pluggable Archive backends with consistent integrity + manifest model.
- Minimal footprint; user data remains on device unless explicitly uploaded to an Archive.

### Non‑Goals

- Cloud service backend or multi‑user server.
- Editing or managing the Photos library itself.
- De‑duplication across different users/libraries (future consideration only).

## 2. Target Platforms & Tech

- **Platforms**: iOS 26, iPadOS 26, macOS 26 (Apple silicon first‑class).
- **Language**: Swift 6 (strict concurrency; Sendable where appropriate).
- **Persistence**: SwiftData.
- **Testing**: Swift Testing (unit, property, and integration suites).
- **Photos Access**: Photos/PhotosUI frameworks; originals via resource requests.
- **Background**: BGProcessingTask (iOS/iPadOS); LaunchAgent/daemon‑less background on macOS within sandbox constraints; user‑initiated long‑running tasks.

## 3. Primary User Flows

1. **Browse & Select**
   - User browses Photos (albums, smart albums, search filters: date range, media type, favourites, edited, live, RAW, video, burst).
   - Selects a set of assets or a saved filter.
2. **Create Archive**
   - Choose type: Folder / NAS / S3.
   - Configure path/URL/bucket, credentials (Keychain), region, connection test.
   - Pick file‑naming and folder scheme (by date, by album, flat, custom pattern) and sidecar options.
3. **Create Export Job**
   - Choose source set (explicit selection or saved filter), target Archive, options (see §7).
   - Review job summary (count, size estimate, conflicts, cost estimate for S3).
   - Start; progress view with per‑item status.
4. **Verify & Maintain**
   - Post‑transfer verification (checksums/ETag/size).
   - Periodic "Audit" runs to re‑verify rot set or entire Archive.

## 4. Requirements

### Functional

- Browse Photos library with performant paging.
- Export "originals" (unedited originals; optional include current edited rendition as separate file).
- Export associated resources: Live Photo video component, RAW+JPEG pairs, bursts, slow‑mo metadata, depth/ProRAW, and sidecars (.xmp, JSON metadata dump).
- Archive backends: Folder (local/external), NAS (SMB/NFS/WebDAV), S3‑compatible.
- Integrity: generate and store SHA‑256 for every exported object; compare against iCloud source hash/size where available; persist Archive Manifest.
- Resumable jobs: persist queue state, retry policy, skip/overwrite rules.
- Scheduling: run immediately, queue, or time‑windowed (e.g., overnight; Wi‑Fi‑only; on power).
- Conflict policies: skip, rename, overwrite if checksum differs, hard‑fail.
- Dry‑run mode: compute changes and expected writes without transferring.
- Audit mode: re‑scan Archive vs source set; report drift and missing/corrupt files; remediate.

### Non‑Functional

- Throughput: target sustained 80+ MB/s to local/NAS on gigabit LAN (device‑bounded), and efficient multipart for S3.
- Robustness: tolerate transient network errors; at‑least‑once semantics; idempotent file naming.
- Privacy: no telemetry by default; opt‑in diagnostics; credentials in Keychain; least‑privilege.
- Accessibility: Dynamic Type, VoiceOver labels, colour‑contrast compliance.
- Localisation: en‑AU first; structure for future locales.

## 5. Architecture

### High‑Level Components

- **PhotosFacade**: read‑only query of Photos library; abstracts asset enumeration and resource pulls for originals.
- **ExportEngine**: orchestrates chunked transfers, retries, concurrency, and verification.
- **Archive Abstraction**: `ArchiveAdapter` protocol with concrete implementations:
  - `FolderArchiveAdapter`
  - `NASArchiveAdapter` (SMB/NFS/WebDAV)
  - `S3ArchiveAdapter` (S3‑compatible, including custom endpoints)
- **Integrity Service**: hashing, manifest updates, periodic audits.
- **Persistence**: SwiftData models for Jobs, Archives, Items, Manifests.
- **UI Layer**: SwiftUI; NavigationSplitView on macOS/iPadOS; NavigationStack on iPhone.

### Concurrency Model

- Isolated executors per adapter (e.g., `@MainActor` for UI, dedicated actors for IO like `TransferActor`, `HashingActor`).
- Back‑pressure via bounded task groups; adaptive concurrency based on thermal/network signals.

## 6. Data Model (SwiftData)

*Indicative schema; finalised during implementation.*

```swift
@Model
final class Archive {
  @Attribute(.unique) var id: UUID
  var name: String
  var kind: ArchiveKind
  var configJSON: Data
  var createdAt: Date
  var updatedAt: Date
}

enum ArchiveKind: String, Codable { case folder, nas, s3 }

@Model
final class ExportJob {
  @Attribute(.unique) var id: UUID
  var createdAt: Date
  var startedAt: Date?
  var finishedAt: Date?
  var status: JobStatus
  var archive: Archive
  var selectionSpecJSON: Data
  var optionsJSON: Data
  var items: [ExportItem]
}

enum JobStatus: String, Codable { case queued, running, paused, failed, completed, cancelled }

@Model
final class ExportItem {
  @Attribute(.unique) var id: UUID
  var job: ExportJob
  var localIdentifier: String
  var filename: String
  var byteSize: Int64
  var checksum: String?
  var state: ItemState
  var errorMessage: String?
}

enum ItemState: String, Codable { case pending, transferring, verifying, done, skipped, failed }

@Model
final class ArchiveRecord {
  @Attribute(.unique) var id: UUID
  var archive: Archive
  var localIdentifier: String
  var path: String
  var byteSize: Int64
  var checksum: String
  var lastVerifiedAt: Date?
}
```

### Manifest

- Per‑Archive **Manifest** persisted in SwiftData and optionally rendered alongside files (`manifest.json` snapshots per job) to enable external validation.

## 7. Export Options

- **What to export**: originals only; originals + current edits; Live Photo components; sidecars (XMP, JSON metadata).
- **Foldering**: `YYYY/MM/YYYY‑MM‑DD/` or by album hierarchy; custom tokenised patterns (e.g., `{year}/{album}/{originalFilename}`).
- **Filenames**: original filename; or pattern using date/time, camera, index.
- **Conflicts**: skip/rename/overwrite‑if‑hash‑differs.
- **Verification**: none | size | SHA‑256 | for S3 also ETag/multipart checksum awareness.
- **Networking**: Wi‑Fi only; on power; cellular allowed caps; bandwidth throttle.
- **Scheduling**: immediate, queued, windowed (time‑of‑day), repeat for new matches.

## 8. Integrity & Verification

- Compute SHA‑256 on bytes written.
- For S3, compare stored ETag and size; if multipart, compute S3 multipart checksum when feasible.
- Store checksum + size in `ArchiveRecord` and job manifest.
- **Audit**: scan Archive filesystem/object list; compare records; mark missing, extra, or corrupted.
- **Repair**: option to re‑export missing/corrupt items.

## 9. Archive Adapters

### FolderArchiveAdapter

- Writes to sandbox‑granted folder (security‑scoped bookmark on macOS; document picker on iOS/iPadOS).
- Supports external drives on macOS.

### NASArchiveAdapter

- Connect via user‑provided URL and credentials; maintain persistent bookmarks where allowed.
- Handle reconnects and transient IO errors; test latency and throughput.

### S3ArchiveAdapter

- Support AWS and S3‑compatible endpoints (custom endpoint/region, access key/secret, or role‑based credentials where available on macOS).
- Multipart uploads with configurable part size; parallel part transfers; abort/retry on part failure; server‑side encryption toggle (SSE‑S3/SSE‑KMS if applicable).
- Optional lifecycle tagging.

## 10. Photos Retrieval Details

- Request **original resources** via Photos framework resource APIs, preserving EXIF/IPTC/XMP.
- Correct handling of: Live Photos (paired MOV), HEIC/HEIF, JPEG, PNG, RAW (DNG/ProRAW), HDR/Depth extras, video codecs, slow‑mo/time‑lapse.
- Respect iCloud "Optimise Storage": fetch from iCloud if not on device; show progress.
- Avoid duplicate exports for the same `localIdentifier` + rendition.

## 11. Background Execution

- iOS/iPadOS: BGProcessingTask with network + power requirements; checkpoint regularly; safe cancellation/resume.
- macOS: long‑running tasks while app is foreground or user‑approved background; handle sleep/wake and external drive ejects.

## 12. UI/UX

- **Shell**: NavigationSplitView (macOS/iPadOS), NavigationStack (iPhone).
- **Screens**:
  - Library browser (grid/list; filters; selection count/size estimate).
  - Archives (list + detail; health indicator; last audit).
  - New/Edit Archive wizard (type → config → verify → naming scheme → review).
  - Jobs (queue with progress; drill‑down to per‑item logs; retry/skip controls).
  - Audits (reports with remediation actions).
  - Settings (network/power, verification defaults, sidecars, privacy).
- **Feedback**: clear progress with throughput, ETA, errors, and retry counts.

## 13. Security & Privacy

- Credentials stored in Keychain (scoped per archive); never written to plaintext storage.
- No analytics by default; optional, explicit opt‑in diagnostics with redaction.
- File access is user‑consented; sandbox bookmarks for persistent folder access.

## 14. Error Handling & Recovery

- Categorise errors: transient (retry with back‑off), permanent (config/auth), content (file corrupt/unavailable), policy (no permission).
- Per‑item retry policy with max attempts; job‑level circuit‑breaker if global issues detected (e.g., auth revoked).
- Export "Incident Report" bundle for support (job log + manifest snapshot).

## 15. Performance & Limits

- Adaptive concurrency based on thermal state and network quality.
- Hashing pipeline avoids double reads (streaming hash while writing when backend allows).
- Large library handling: process in batches, lazy paging, memory caps.

## 16. Testing Strategy (Swift Testing)

- Unit tests for naming patterns, hashing, manifest diffs, conflict rules.
- Protocol‑level contract tests for all `ArchiveAdapter` implementations.
- Integration tests with temporary folders and a mock S3 server.
- Property-based testing for file naming patterns and checksum validation.
- Performance tests for large library handling and concurrent transfers.
- UI automation tests for critical user flows.

## 17. Success Criteria

- Successfully export 10,000+ photos with 100% integrity verification
- Achieve target throughput of 80+ MB/s on local/gigabit LAN
- Handle network interruptions gracefully with automatic resume
- Support all major photo formats (HEIC, RAW, Live Photos, etc.)
- Pass accessibility audits for Dynamic Type and VoiceOver
- Zero credential leakage or unintended data exposure