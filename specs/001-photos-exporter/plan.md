# Implementation Plan: Photos Exporter

**Branch**: `001-photos-exporter` | **Date**: 2025-09-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Users/jamielesouef/Developer/extract/specs/001-photos-exporter/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, or `GEMINI.md` for Gemini CLI).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
8. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Photos Exporter is a privacy-respecting, cross-platform Apple app that allows users to browse their Photos library and create export jobs to download original, full-resolution assets from iCloud to various Archive destinations (local folders, NAS, S3-compatible storage). The app maintains verifiable consistency records to ensure parity between iCloud originals and archived copies using SwiftData persistence and Swift 6 concurrency.

## Technical Context
**Language/Version**: Swift 6 (strict concurrency, Sendable where appropriate)  
**Primary Dependencies**: Photos/PhotosUI frameworks, SwiftData, BGProcessingTask  
**Storage**: SwiftData for persistence, Keychain for credentials  
**Testing**: Swift Testing (unit, property, and integration suites)  
**Target Platform**: iOS 18+, iPadOS 18+, macOS 26+ (Apple silicon first-class)
**Project Type**: mobile - native Apple app across platforms  
**Performance Goals**: 80+ MB/s sustained throughput to local/NAS on gigabit LAN  
**Constraints**: Privacy-first (no telemetry by default), sandbox constraints, iCloud rate limits  
**Scale/Scope**: 10,000+ photos per job, multiple concurrent transfers, large library handling

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 1 (iOS/macOS app with integrated libraries)
- Using framework directly? YES (Photos/PhotosUI, SwiftData directly)
- Single data model? YES (SwiftData models without DTOs)
- Avoiding patterns? YES (no Repository/UoW - direct SwiftData access)

**Architecture**:
- EVERY feature as library? ADAPTED (Libraries as Swift modules within app)
- Libraries planned: PhotosFacade, ExportEngine, ArchiveAdapters, IntegrityService
- CLI per library: N/A (Native app, not CLI-based)
- Library docs: Swift documentation comments + README

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? YES (Swift Testing framework)
- Git commits show tests before implementation? YES (TDD approach)
- Order: Contract→Integration→Unit (adapted for iOS)
- Real dependencies used? YES (actual Photos library, file system, network)
- Integration tests for: Archive adapters, Photos integration, SwiftData persistence
- FORBIDDEN: Implementation before test, skipping RED phase

**Observability**:
- Structured logging included? YES (slog.swift already exists in project)
- App logs unified? YES (single app target, unified logging)
- Error context sufficient? YES (detailed error categorization planned)

**Versioning**:
- Version number assigned? 0.1.0 (MAJOR.MINOR.PATCH)
- BUILD increments on every change? YES (automated via build system)
- Breaking changes handled? YES (SwiftData migration plan)

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 1 (Single project) - Native iOS/macOS app with standard Swift project structure

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `/scripts/update-agent-context.sh [claude|gemini|copilot]` for your AI assistant
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- **Contract Test Tasks** [P]: One task per service protocol (4 protocols)
- **Model Creation Tasks** [P]: SwiftData models for Archive, ExportJob, ExportItem, ArchiveRecord, AuditLog
- **Service Implementation Tasks**: PhotosService, ExportService, ArchiveService, IntegrityService
- **Archive Adapter Tasks** [P]: FolderAdapter, NASAdapter, S3Adapter implementations
- **UI Integration Tasks**: Archive management UI, Export job creation, Progress monitoring
- **Integration Test Tasks**: End-to-end user flows from quickstart.md

**Ordering Strategy**:
- **Phase A - Foundation** (TDD): Contract tests → Models → Service interfaces
- **Phase B - Services** (TDD): Service implementations → Service tests
- **Phase C - Adapters** (Parallel): Archive adapter implementations + tests
- **Phase D - UI Integration**: SwiftUI views → UI tests
- **Phase E - System Tests**: Integration tests → Performance validation
- Mark [P] for parallel execution within phases

**Task Categories**:
1. **Contract Tests** (4 tasks): Test protocol compliance before implementation
2. **Data Models** (5 tasks): SwiftData model creation with validation
3. **Service Layer** (8 tasks): Core business logic implementation
4. **Archive Adapters** (6 tasks): Storage backend implementations 
5. **UI Components** (10 tasks): SwiftUI views for all user flows
6. **Integration Tests** (6 tasks): End-to-end scenario validation
7. **Performance & Polish** (4 tasks): Optimization and final testing

**Estimated Output**: 43 numbered, ordered tasks in tasks.md organized by TDD principles

**Dependencies**:
- Contract tests must pass before implementations
- Models must exist before services
- Services must exist before UI
- All core functionality complete before integration tests

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*