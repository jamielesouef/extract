# Tasks: Photos Exporter

**Input**: Design documents from `/Users/jamielesouef/Developer/extract/specs/001-photos-exporter/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓)

## Execution Flow (main)
```
1. Load plan.md from feature directory ✓
   → Extract: Swift 6, SwiftData, PhotoKit, BGProcessingTask
2. Load design documents ✓:
   → data-model.md: 5 entities → model tasks
   → contracts/: 4 service protocols → contract test tasks
   → research.md: Actor-based isolation, archive adapters
3. Generate tasks by category:
   → Setup: SwiftData schema, service protocols
   → Tests: contract tests, integration tests
   → Core: models, services, archive adapters
   → Integration: UI, background processing
   → Polish: unit tests, performance, audit
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness ✓
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Native iOS/macOS app**: `extract/` source, `extractTests/` tests
- Paths use existing project structure from Xcode project

## Phase 3.1: Setup
- [ ] T001 Create SwiftData schema file at `extract/Model/PhotosExporter/Schema.swift`
- [ ] T002 [P] Initialize service protocol files in `extract/Services/PhotosExporter/`
- [ ] T003 [P] Configure Swift 6 concurrency settings in project

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Contract Tests (Service Protocols)
- [ ] T004 [P] Contract test PhotosServiceProtocol in `extractTests/Services/PhotosServiceContractTests.swift`
- [ ] T005 [P] Contract test ExportServiceProtocol in `extractTests/Services/ExportServiceContractTests.swift`
- [ ] T006 [P] Contract test ArchiveServiceProtocol in `extractTests/Services/ArchiveServiceContractTests.swift`
- [ ] T007 [P] Contract test IntegrityServiceProtocol in `extractTests/Services/IntegrityServiceContractTests.swift`

### Model Tests
- [ ] T008 [P] Archive model tests in `extractTests/Models/ArchiveTests.swift`
- [ ] T009 [P] ExportJob model tests in `extractTests/Models/ExportJobTests.swift`
- [ ] T010 [P] ExportItem model tests in `extractTests/Models/ExportItemTests.swift`
- [ ] T011 [P] ArchiveRecord model tests in `extractTests/Models/ArchiveRecordTests.swift`
- [ ] T012 [P] AuditLog model tests in `extractTests/Models/AuditLogTests.swift`

### Integration Tests (User Stories)
- [ ] T013 [P] Basic local export integration test in `extractTests/Integration/LocalExportTests.swift`
- [ ] T014 [P] S3 export with progress monitoring test in `extractTests/Integration/S3ExportTests.swift`
- [ ] T015 [P] NAS export with error recovery test in `extractTests/Integration/NASExportTests.swift`
- [ ] T016 [P] Large library performance test in `extractTests/Integration/PerformanceTests.swift`
- [ ] T017 [P] Background processing test in `extractTests/Integration/BackgroundTests.swift`
- [ ] T018 [P] Audit and repair integration test in `extractTests/Integration/AuditRepairTests.swift`

## Phase 3.3: Core Implementation (ONLY after tests are failing)

### SwiftData Models
- [ ] T019 [P] Archive model in `extract/Model/PhotosExporter/Archive.swift`
- [ ] T020 [P] ExportJob model in `extract/Model/PhotosExporter/ExportJob.swift`
- [ ] T021 [P] ExportItem model in `extract/Model/PhotosExporter/ExportItem.swift`
- [ ] T022 [P] ArchiveRecord model in `extract/Model/PhotosExporter/ArchiveRecord.swift`
- [ ] T023 [P] AuditLog model in `extract/Model/PhotosExporter/AuditLog.swift`

### Service Implementations
- [ ] T024 PhotosService implementation in `extract/Services/PhotosExporter/PhotosService.swift`
- [ ] T025 ExportService implementation in `extract/Services/PhotosExporter/ExportService.swift`
- [ ] T026 ArchiveService implementation in `extract/Services/PhotosExporter/ArchiveService.swift`
- [ ] T027 IntegrityService implementation in `extract/Services/PhotosExporter/IntegrityService.swift`

### Archive Adapters
- [ ] T028 [P] FolderArchiveAdapter in `extract/Services/PhotosExporter/Adapters/FolderAdapter.swift`
- [ ] T029 [P] NASArchiveAdapter in `extract/Services/PhotosExporter/Adapters/NASAdapter.swift`
- [ ] T030 [P] S3ArchiveAdapter in `extract/Services/PhotosExporter/Adapters/S3Adapter.swift`

### Core Utilities
- [ ] T031 [P] Checksum utilities in `extract/Common/PhotosExporter/ChecksumUtils.swift`
- [ ] T032 [P] File naming patterns in `extract/Common/PhotosExporter/NamingUtils.swift`
- [ ] T033 [P] Progress tracking utilities in `extract/Common/PhotosExporter/ProgressUtils.swift`

## Phase 3.4: UI Integration

### Archive Management Views
- [ ] T034 [P] Archive list view in `extract/Views/PhotosExporter/Archives/ArchiveListView.swift`
- [ ] T035 [P] Archive creation view in `extract/Views/PhotosExporter/Archives/CreateArchiveView.swift`
- [ ] T036 [P] Archive configuration views in `extract/Views/PhotosExporter/Archives/ConfigViews/`

### Export Job Views
- [ ] T037 [P] Export job creation view in `extract/Views/PhotosExporter/Export/CreateExportView.swift`
- [ ] T038 [P] Job progress monitoring view in `extract/Views/PhotosExporter/Export/JobProgressView.swift`
- [ ] T039 [P] Job management view in `extract/Views/PhotosExporter/Export/JobListView.swift`

### Selection and Configuration
- [ ] T040 [P] Photo selection interface in `extract/Views/PhotosExporter/Selection/PhotoSelectionView.swift`
- [ ] T041 [P] Smart filter configuration in `extract/Views/PhotosExporter/Selection/SmartFiltersView.swift`
- [ ] T042 [P] Export options configuration in `extract/Views/PhotosExporter/Export/ExportOptionsView.swift`

### Audit and Monitoring
- [ ] T043 [P] Audit report view in `extract/Views/PhotosExporter/Audit/AuditReportView.swift`
- [ ] T044 [P] Repair plan view in `extract/Views/PhotosExporter/Audit/RepairPlanView.swift`
- [ ] T045 [P] System status dashboard in `extract/Views/PhotosExporter/Status/StatusDashboardView.swift`

## Phase 3.5: Background Processing & System Integration

### Background Tasks
- [ ] T046 Background export processing in `extract/Services/PhotosExporter/BackgroundExportManager.swift`
- [ ] T047 BGProcessingTask integration for iOS in `extract/Services/PhotosExporter/BackgroundTaskManager.swift`
- [ ] T048 [P] Checkpoint and resume logic in `extract/Services/PhotosExporter/CheckpointManager.swift`

### System Integration
- [ ] T049 Keychain integration for credentials in `extract/Services/PhotosExporter/KeychainManager.swift`
- [ ] T050 [P] Network monitoring in `extract/Services/PhotosExporter/NetworkMonitor.swift`
- [ ] T051 [P] Thermal state monitoring in `extract/Services/PhotosExporter/ThermalMonitor.swift`

### App Integration
- [ ] T052 Update main navigation for Photos Exporter in `extract/Views/NavigationOptions.swift`
- [ ] T053 Environment setup for Photos Exporter services in `extract/extractApp.swift`
- [ ] T054 Update AppState for export job management in `extract/Model/AppState.swift`

## Phase 3.6: Polish & Performance

### Unit Tests (Additional Coverage)
- [ ] T055 [P] Archive adapter unit tests in `extractTests/Services/Adapters/`
- [ ] T056 [P] Checksum utilities tests in `extractTests/Common/ChecksumUtilsTests.swift`
- [ ] T057 [P] Naming pattern tests in `extractTests/Common/NamingUtilsTests.swift`
- [ ] T058 [P] Background manager tests in `extractTests/Services/BackgroundManagerTests.swift`

### Performance Optimization
- [ ] T059 Concurrent transfer optimisation in existing services
- [ ] T060 Memory management for large transfers in existing services
- [ ] T061 [P] Performance benchmarking suite in `extractTests/Performance/BenchmarkTests.swift`

### Documentation & Polish
- [ ] T062 [P] Update project README with Photos Exporter features
- [ ] T063 [P] Add SwiftDoc comments to all public interfaces
- [ ] T064 [P] Create quickstart validation script at `scripts/validate-quickstart.sh`
- [ ] T065 Final integration testing per quickstart scenarios

## Dependencies

### Critical Path Dependencies
- **Setup** (T001-T003) → **All other tasks**
- **Contract Tests** (T004-T007) → **Service Implementation** (T024-T027)
- **Model Tests** (T008-T012) → **Model Implementation** (T019-T023)
- **Models** (T019-T023) → **Services** (T024-T027)
- **Services** (T024-T027) → **UI Integration** (T034-T045)
- **Core Implementation** (T019-T033) → **Background Processing** (T046-T051)

### Parallel Execution Blocks
- **Block 1**: Contract tests T004-T007 (different protocols)
- **Block 2**: Model tests T008-T012 (different models)
- **Block 3**: Integration tests T013-T018 (different scenarios)
- **Block 4**: Model implementations T019-T023 (different files)
- **Block 5**: Archive adapters T028-T030 (different backends)
- **Block 6**: UI views T034-T045 (different view files)

## Parallel Execution Examples

### Phase 3.2 Contract Tests (Parallel Launch)
```
Task: "Contract test PhotosServiceProtocol in extractTests/Services/PhotosServiceContractTests.swift"
Task: "Contract test ExportServiceProtocol in extractTests/Services/ExportServiceContractTests.swift"
Task: "Contract test ArchiveServiceProtocol in extractTests/Services/ArchiveServiceContractTests.swift"
Task: "Contract test IntegrityServiceProtocol in extractTests/Services/IntegrityServiceContractTests.swift"
```

### Phase 3.3 Model Implementation (Parallel Launch)
```
Task: "Archive model in extract/Model/PhotosExporter/Archive.swift"
Task: "ExportJob model in extract/Model/PhotosExporter/ExportJob.swift"
Task: "ExportItem model in extract/Model/PhotosExporter/ExportItem.swift"
Task: "ArchiveRecord model in extract/Model/PhotosExporter/ArchiveRecord.swift"
Task: "AuditLog model in extract/Model/PhotosExporter/AuditLog.swift"
```

### Phase 3.3 Archive Adapters (Parallel Launch)
```
Task: "FolderArchiveAdapter in extract/Services/PhotosExporter/Adapters/FolderAdapter.swift"
Task: "NASArchiveAdapter in extract/Services/PhotosExporter/Adapters/NASAdapter.swift"
Task: "S3ArchiveAdapter in extract/Services/PhotosExporter/Adapters/S3Adapter.swift"
```

## Task Categories Summary

1. **Setup Tasks** (3): Project structure and configuration
2. **Contract Tests** (4): Service protocol compliance tests
3. **Model Tests** (5): SwiftData model validation tests
4. **Integration Tests** (6): End-to-end user scenario tests
5. **Core Models** (5): SwiftData model implementations
6. **Services** (4): Business logic service implementations
7. **Archive Adapters** (3): Storage backend implementations
8. **Utilities** (3): Common functionality and helpers
9. **UI Components** (12): SwiftUI views for all user flows
10. **Background Processing** (3): Background task management
11. **System Integration** (6): Platform integration and app updates
12. **Performance & Polish** (11): Testing, optimisation, documentation

**Total Tasks**: 65 numbered, ordered tasks organised by TDD principles

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task completion
- Follow Swift 6 strict concurrency requirements
- Use SwiftData best practices for model relationships
- Implement proper error handling and progress reporting

## Validation Checklist
*GATE: All items verified before task execution*

- [x] All contracts (4) have corresponding tests (T004-T007)
- [x] All entities (5) have model tasks (T019-T023)
- [x] All tests come before implementation (Phase 3.2 → 3.3)
- [x] Parallel tasks truly independent (different files marked [P])
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Integration tests cover all quickstart scenarios (T013-T018)
- [x] UI tasks cover complete user experience (T034-T045)
- [x] Background processing properly isolated (T046-T048)
- [x] Performance requirements addressed (T059-T061)

## Success Criteria
- All 65 tasks completed successfully
- All contract tests pass
- All integration tests validate quickstart scenarios  
- Performance benchmarks meet targets (20+ photos/sec, 5+ MB/s)
- UI provides complete user experience for all flows
- Background processing works on iOS/macOS
- Audit and repair functionality fully operational
- Code follows Swift 6 concurrency best practices
