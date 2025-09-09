# Tasks: Photos Exporter

**Input**: Design documents from `/Users/jamielesouef/Developer/extract/specs/001-photos-exporter/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Tech stack: Swift 6, SwiftData, Photos/PhotosUI, BGProcessingTask
   → Structure: iOS/macOS app with integrated libraries
2. Load design documents:
   → data-model.md: 5 entities (Archive, ExportJob, ExportItem, ArchiveRecord, AuditLog)
   → contracts/: 4 service protocols 
   → quickstart.md: 6 integration test scenarios
3. Generate 43 tasks across 7 categories
4. Apply TDD ordering: Tests → Models → Services → Adapters → UI → Integration
5. Mark [P] for parallel execution (different files, no dependencies)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
Single iOS/macOS project structure:
- **Models**: `extract/Model/`
- **Services**: `extract/Services/`  
- **Views**: `extract/Views/`
- **Tests**: `extractTests/`

## Phase 3.1: Setup

- [ ] **T001** Initialize Swift 6 strict concurrency in project settings and update deployment targets to iOS 18+/macOS 26+
- [ ] **T002** Add SwiftData framework dependency and configure container with in-memory storage for development
- [ ] **T003** [P] Configure SwiftFormat (replacing SwiftLint) and update build scripts in Makefile

## Phase 3.2: Contract Tests (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] **T004** [P] Contract test for PhotosServiceProtocol in `extractTests/PhotosServiceContractTests.swift`
- [ ] **T005** [P] Contract test for ExportServiceProtocol in `extractTests/ExportServiceContractTests.swift`
- [ ] **T006** [P] Contract test for ArchiveServiceProtocol in `extractTests/ArchiveServiceContractTests.swift`
- [ ] **T007** [P] Contract test for IntegrityServiceProtocol in `extractTests/IntegrityServiceContractTests.swift`

## Phase 3.3: Data Models (ONLY after contract tests are failing)

- [ ] **T008** [P] Archive SwiftData model with ArchiveKind enum in `extract/Model/Archive.swift`
- [ ] **T009** [P] ExportJob SwiftData model with JobStatus enum in `extract/Model/ExportJob.swift`
- [ ] **T010** [P] ExportItem SwiftData model with ItemState enum in `extract/Model/ExportItem.swift`
- [ ] **T011** [P] ArchiveRecord SwiftData model for audit trail in `extract/Model/ArchiveRecord.swift`
- [ ] **T012** [P] AuditLog SwiftData model with issue tracking in `extract/Model/AuditLog.swift`

## Phase 3.4: Service Layer Implementation

- [ ] **T013** PhotosService implementation with @MainActor isolation in `extract/Services/PhotosService.swift`
- [ ] **T014** ExportService implementation with job orchestration in `extract/Services/ExportService.swift`
- [ ] **T015** ArchiveService implementation with backend management in `extract/Services/ArchiveService.swift`
- [ ] **T016** IntegrityService actor implementation for checksum operations in `extract/Services/IntegrityService.swift`
- [ ] **T017** [P] SelectionSpec and ExportOptions configuration structs in `extract/Model/Configuration.swift`
- [ ] **T018** [P] AssetResource and supporting types in `extract/Model/AssetTypes.swift`
- [ ] **T019** [P] Error types for all services in `extract/Common/ExportErrors.swift`
- [ ] **T020** Background task manager for BGProcessingTask integration in `extract/Services/BackgroundTaskManager.swift`

## Phase 3.5: Archive Adapters (Parallel Implementation)

- [ ] **T021** [P] FolderArchiveAdapter for local/external storage in `extract/Services/Adapters/FolderArchiveAdapter.swift`
- [ ] **T022** [P] NASArchiveAdapter for SMB/WebDAV in `extract/Services/Adapters/NASArchiveAdapter.swift`
- [ ] **T023** [P] S3ArchiveAdapter for S3-compatible storage in `extract/Services/Adapters/S3ArchiveAdapter.swift`
- [ ] **T024** [P] ArchiveAdapter base protocol and factory in `extract/Services/Adapters/ArchiveAdapter.swift`
- [ ] **T025** [P] Credential management with Keychain integration in `extract/Services/CredentialManager.swift`
- [ ] **T026** [P] Network connectivity and progress monitoring utilities in `extract/Common/NetworkUtilities.swift`

## Phase 3.6: UI Components

- [ ] **T027** Archive configuration view with type selection in `extract/Views/ArchiveConfigurationView.swift`
- [ ] **T028** Archive list view with connection status in `extract/Views/ArchiveListView.swift`
- [ ] **T029** Export job creation wizard in `extract/Views/ExportJobCreationView.swift`
- [ ] **T030** Export progress monitoring view in `extract/Views/ExportProgressView.swift`
- [ ] **T031** Photo selection interface with filters in `extract/Views/PhotoSelectionView.swift`
- [ ] **T032** Export options configuration view in `extract/Views/ExportOptionsView.swift`
- [ ] **T033** Job queue management view in `extract/Views/JobQueueView.swift`
- [ ] **T034** Audit results and repair interface in `extract/Views/AuditView.swift`
- [ ] **T035** Settings view for app preferences in `extract/Views/SettingsView.swift`
- [ ] **T036** Update main navigation to include export features in `extract/Views/ExtractSplitView.swift`

## Phase 3.7: Service Integration Tests

- [ ] **T037** [P] PhotosService integration test with mock Photos library in `extractTests/PhotosServiceIntegrationTests.swift`
- [ ] **T038** [P] ArchiveAdapter integration tests with test storage in `extractTests/ArchiveAdapterIntegrationTests.swift`
- [ ] **T039** [P] SwiftData persistence integration tests in `extractTests/DataPersistenceIntegrationTests.swift`
- [ ] **T040** [P] Background processing integration tests in `extractTests/BackgroundProcessingIntegrationTests.swift`

## Phase 3.8: End-to-End Validation

- [ ] **T041** Basic local export end-to-end test (Quickstart Scenario 1) in `extractTests/BasicExportE2ETests.swift`
- [ ] **T042** S3 export with progress monitoring test (Quickstart Scenario 2) in `extractTests/S3ExportE2ETests.swift`
- [ ] **T043** Performance validation for 1000+ photos (Quickstart Scenario 4) in `extractTests/PerformanceTests.swift`

## Dependencies

**Phase Dependencies:**
- Contract tests (T004-T007) → All implementation tasks
- Data models (T008-T012) → Service layer (T013-T020)
- Service layer → Archive adapters (T021-T026)
- Services + Adapters → UI components (T027-T036)
- All core functionality → Integration tests (T037-T040)
- Complete system → E2E validation (T041-T043)

**Critical Blocking Dependencies:**
- T008 (Archive model) blocks T013, T015, T021-T024
- T009-T010 (Job models) blocks T014, T027-T034
- T013-T016 (Services) blocks T027-T036 (UI)
- T021-T023 (Adapters) blocks T027-T028 (Archive UI)
- T025 (Credentials) blocks T022-T023 (Network adapters)

## Parallel Execution Examples

### Contract Tests Phase (Run in parallel):
```bash
Task: "Contract test PhotosServiceProtocol in extractTests/PhotosServiceContractTests.swift"
Task: "Contract test ExportServiceProtocol in extractTests/ExportServiceContractTests.swift"  
Task: "Contract test ArchiveServiceProtocol in extractTests/ArchiveServiceContractTests.swift"
Task: "Contract test IntegrityServiceProtocol in extractTests/IntegrityServiceContractTests.swift"
```

### Data Models Phase (Run in parallel):
```bash
Task: "Archive SwiftData model with ArchiveKind enum in extract/Model/Archive.swift"
Task: "ExportJob SwiftData model with JobStatus enum in extract/Model/ExportJob.swift"
Task: "ExportItem SwiftData model with ItemState enum in extract/Model/ExportItem.swift"
Task: "ArchiveRecord SwiftData model for audit trail in extract/Model/ArchiveRecord.swift"
Task: "AuditLog SwiftData model with issue tracking in extract/Model/AuditLog.swift"
```

### Archive Adapters Phase (Run in parallel):
```bash
Task: "FolderArchiveAdapter for local/external storage in extract/Services/Adapters/FolderArchiveAdapter.swift"
Task: "NASArchiveAdapter for SMB/WebDAV in extract/Services/Adapters/NASArchiveAdapter.swift"
Task: "S3ArchiveAdapter for S3-compatible storage in extract/Services/Adapters/S3ArchiveAdapter.swift"
```

## Notes

- **[P] tasks** = different files, no dependencies, can run concurrently
- **TDD Enforcement**: All contract tests (T004-T007) must be written and failing before any implementation
- **Swift 6 Compliance**: All code must use strict concurrency with proper actor isolation
- **Performance Requirements**: Target 80+ MB/s throughput, handle 10,000+ photos
- **Platform Support**: Ensure compatibility with iOS 18+, iPadOS 18+, macOS 26+
- **Privacy First**: No telemetry, credentials in Keychain only
- **Commit Strategy**: Commit after each task completion
- **Testing Strategy**: Use Swift Testing framework throughout

## Task Generation Rules Applied

1. **From Contracts**: 4 service protocols → 4 contract test tasks [P]
2. **From Data Model**: 5 entities → 5 model creation tasks [P]  
3. **From Architecture**: Service layer → 8 service implementation tasks
4. **From Storage Needs**: 3 adapters → 6 adapter implementation tasks
5. **From User Stories**: 6 scenarios → 10 UI + 6 validation tasks
6. **From Technical Requirements**: Swift 6, performance → setup and optimization tasks

## Validation Checklist

- [x] All contracts have corresponding tests (T004-T007)
- [x] All entities have model tasks (T008-T012)  
- [x] All tests come before implementation (T004-T007 before T013+)
- [x] Parallel tasks are truly independent (verified file paths)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] 43 tasks generated as estimated in plan.md
- [x] TDD ordering enforced: Tests → Models → Services → UI → Integration