# Repository Guidelines

## Project Structure & Module Organization
- Source code in `extract/` (SwiftUI app): `Model/`, `Services/`, `Views/`, `Resources/`, `Common/`. Xcode project: `extract.xcodeproj`.
- Tests in `extractTests/`: `Unit/` and `Integration/` plus top-level suites (e.g., `NavigationOptionsTests.swift`).
- Tooling and docs: `scripts/` (automation, smart commit), `specs/` (feature specs and contracts), `templates/` (authoring templates), `build/` (artifacts).

## Build, Test, and Development Commands
- `make help` – List available tasks.
- `make setup` – Install SwiftFormat and GitHub CLI (via Homebrew).
- `make format` – Format Swift code (uses repo `.swiftformat`).
- `make build` – Format, then build with `xcodebuild`.
- `make run` – Build and launch the macOS app.
- `make test` – Build test target (run tests interactively in Xcode).
- `make open` – Open the project in Xcode.
- `make clean` – Clean build artifacts.
- `make commit` – Run smart commit workflow in `scripts/smart-commit.sh`.

## Coding Style & Naming Conventions
- Swift 6; 2-space indentation; no semicolons; Allman off; unused `self` removed (enforced by SwiftFormat).
- Imports alphabetized; collections wrapped before first element.
- Types `UpperCamelCase`; methods/properties `lowerCamelCase`; constants in `Constants.swift`.
- SwiftUI views end with `View` (e.g., `PhotosView`); files named after primary type.
- Concurrency: mark UI with `@MainActor`; keep long-running I/O off the main thread.

## Testing Guidelines
- Framework: Swift Testing (`import Testing`, `@Suite`, `@Test`).
- Location: `extractTests/Unit/**` and `extractTests/Integration/**`; name files `*Tests.swift`.
- Coverage requirement: 100% line/function coverage for all modules except SwiftUI views. Required areas: `Model/`, `Services/`, `Common/`, and non-UI helpers. Views are exercised via integration/snapshot tests as feasible but excluded from coverage gates.
- Run: `make test` to build tests; use Xcode to execute, view coverage, and enforce thresholds. Focus on edge cases (PhotoKit access, selection state, MediaStore indexing, error handling).

## Commit & Pull Request Guidelines
- Use `make commit` to auto-format, build, analyze changes, and craft a descriptive message. Keep subjects imperative and scoped (e.g., “Add photo selection overlay”).
- Group related changes; include tests for new behaviour. Reference issues with `#123` when applicable.
- PRs must include: clear description, linked issues, UI screenshots (if visual changes), test plan/steps, and confirmation that `make build` and `make format` pass.
- Prefer feature branches named after spec IDs when relevant (e.g., `002-photo-grid`).

## Security & Configuration Tips
- Do not commit secrets or tokens. Configure S3/NAS credentials via the system keychain or environment, not source control.
- Keep large media out of the repo; place app assets in `extract/Resources/Assets.xcassets`.
- Ensure Photos/iCloud permissions are correctly configured for local testing.

## Agent-Specific Notes
- See `CLAUDE.md` for assistant context. Keep diffs minimal and focused; follow the Makefile for tooling; avoid unrelated refactors.
