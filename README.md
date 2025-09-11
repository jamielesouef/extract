# 📸 Extract (working name)

**Project Vision**  
Extract gives you full control over your iCloud Photo Library. While Photos is great for browsing and syncing, exporting your entire library to a destination of your choice — an external drive, a NAS at home, or cloud storage like Amazon S3 — is still awkward. Extract fills that gap with a clean, cross-platform app that makes exporting photos and videos simple, reliable, and future-proof.

## ✨ Features
- Runs on **macOS 26, iOS 26, and iPadOS 26**.
- **Browse and select** photos and videos from your iCloud Photo Library.
- **Export anywhere**:
  - Local folders or external drives
  - **NAS** (e.g. SMB shares)
  - **Amazon S3** buckets (more services coming soon)
- **Pull to refresh** to re-scan for newly added items.
- Designed to handle **large libraries** smoothly.

## 🛠 Requirements
- macOS 26 / iOS 26 / iPadOS 26 or later
- Xcode 16 or later
- iCloud Photos enabled on the device
- Permissions: Photos access and Files access (for writing to destinations)
- Optional: Network access for NAS shares; S3 credentials with write permissions if exporting to S3

## 📦 Installation
Clone the repository and set up the development environment:

```bash
git clone https://github.com/jamielesouef/extract.git
cd extract
```

### Prerequisites
- **Xcode 16** or later
- **SwiftFormat** (for code formatting)
- **GitHub CLI** (for pull requests and GitHub integration)

Install dependencies:
```bash
make setup  # Installs SwiftFormat and GitHub CLI via Homebrew
```

### Building the Project

**Using Makefile (Recommended):**
```bash
make help        # Show all available commands
make open        # Open project in Xcode
make format      # Run SwiftFormat on source code
make build       # Build the project (runs format first)
make run         # Build and run the app
make test        # Run unit tests
make clean       # Clean build artifacts
make commit      # Create intelligent commit using current changes
```

**Using Xcode:**
```bash
open extract.xcodeproj
```
Then build and run with Cmd+R.

## Run on macOS 15+ (Will only support 26 when shipped), iPhone 26, or iPadOS 26 with iCloud Photos enabled.

### 🚀 Usage
	1.	Launch the app and grant access to your iCloud Photo Library.
	2.	Browse your library inside the app.
	3.	Choose your destination — local folder, NAS path, or S3 bucket.
	4.	Start the export process and track progress in the app.
	5.	Pull down to refresh when you’ve added new photos and want to sync them.

### 📜 Roadmap
	•	Support for more cloud providers (e.g. Dropbox, Google Drive).
	•	Export presets (original, compressed, or converted formats).
	•	Progress indicators with resumable exports.
	•	Scheduling automatic syncs.

### 🤝 Contributing

Issues and PRs are welcome. Please open an issue to discuss significant changes before submitting a PR.

#### Development Workflow
1. Clone the repository and run `make setup`
2. Use `make build` to ensure code passes formatting before committing
3. Run `make format` to format code style
4. Use `make test` to run the test suite
5. Use `make commit` for intelligent commit creation

The project uses SwiftFormat for code formatting and GitHub CLI for pull request management. All builds automatically run formatting checks to maintain consistent code style.

## Documentation
- [Product & Technical Spec](./SPEC.md)
