# Extract - Makefile
# SwiftUI macOS/iOS app for photo library export

.PHONY: help format build clean test test-macos test-ios test-all run setup format-fix open commit

# Default target
help:
	@echo "Extract - Available commands:"
	@echo "  make open        - Open project in Xcode"
	@echo "  make format      - Run SwiftFormat on source code"
	@echo "  make build       - Build the project (runs format first)"
	@echo "  make run         - Build and run the app"
	@echo "  make test               - Run unit tests on both platforms (default)"
	@echo "  make test platform=macos - Run unit tests on macOS only"
	@echo "  make test platform=ios   - Run unit tests on iOS Simulator only"
	@echo "  make test-macos         - Run unit tests on macOS (alias)"
	@echo "  make test-ios           - Run unit tests on iOS Simulator (alias)"
	@echo "  make test-all           - Run unit tests on both platforms (alias)"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make setup       - Install development dependencies (SwiftFormat, GitHub CLI)"
	@echo "  make commit      - Create intelligent commit using current changes"

# Install development dependencies
setup:
	@echo "Setting up development environment..."
	@if ! which brew > /dev/null; then \
		echo "Error: Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi
	@echo "Installing SwiftFormat..."
	brew install swiftformat
	@echo "Installing GitHub CLI..."
	brew install gh
	@echo "✅ Development environment setup complete!"
	@echo "💡 You can now use 'gh auth login' to authenticate with GitHub"

# Run SwiftFormat
format:
	@echo "Running SwiftFormat..."
	swiftformat .

# Build the project (with formatting and tests)
build: format test
	@echo "Building Extract..."
	xcodebuild -project extract.xcodeproj -scheme extract -configuration Debug build

# Build for release
release: format
	@echo "Building Extract for Release..."
	xcodebuild -project extract.xcodeproj -scheme extract -configuration Release build

# Build and run the app
run: build
	@echo "Launching Extract..."
	open /Users/jamielesouef/Library/Developer/Xcode/DerivedData/extract-*/Build/Products/Debug/extract.app

# Run tests with platform support (defaults to both platforms)
# Usage: make test, make test platform=macos, make test platform=ios, make test platform=all
test: format
	@if [ "$(platform)" = "macos" ]; then \
		echo "Running tests on macOS..."; \
		xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=macOS'; \
	elif [ "$(platform)" = "ios" ]; then \
		echo "Running tests on iOS Simulator..."; \
		xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=iOS Simulator,name=iPhone 17'; \
	else \
		echo "Running tests on both macOS and iOS..."; \
		echo "Running tests on macOS..."; \
		xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=macOS'; \
		echo "Running tests on iOS Simulator..."; \
		xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=iOS Simulator,name=iPhone 17'; \
	fi

# Convenience aliases for backward compatibility
test-macos: format
	@echo "Running tests on macOS..."
	xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=macOS'

test-ios: format
	@echo "Running tests on iOS Simulator..."
	xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=iOS Simulator,name=iPhone 17'

test-all: format
	@echo "Running tests on both macOS and iOS..."
	@echo "Running tests on macOS..."
	xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=macOS'
	@echo "Running tests on iOS Simulator..."
	xcodebuild test -project extract.xcodeproj -scheme extract -destination 'platform=iOS Simulator,name=iPhone 17'

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	xcodebuild -project extract.xcodeproj -scheme extract clean
	rm -rf ~/Library/Developer/Xcode/DerivedData/extract-*

# Fix formatting issues automatically where possible
format-fix:
	@echo "Auto-fixing formatting issues..."
	swiftformat .

# Open project in Xcode
open:
	@echo "Opening Extract project in Xcode..."
	open extract.xcodeproj

# Create intelligent commit using current changes
commit:
	@echo "🚀 Starting smart commit process..."
	@./scripts/smart-commit.sh --yes