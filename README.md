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
git clone https://github.com/<your-org>/<repo>.git
cd extract
```

### Prerequisites
- **Xcode 16** or later
- **SwiftLint** (for code quality)

Install dependencies:
```bash
make install-deps  # Installs SwiftLint via Homebrew
```

### Building the Project

**Using Makefile (Recommended):**
```bash
make help        # Show all available commands
make build       # Build with linting
make run         # Build and launch app
make test        # Run tests
make clean       # Clean build artifacts
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
1. Clone the repository and run `make install-deps`
2. Use `make build` to ensure code passes linting before committing
3. Run `make lint` to check code style
4. Use `make test` to run the test suite

The project uses SwiftLint for code quality. All builds automatically run linting checks to maintain consistent code style.
