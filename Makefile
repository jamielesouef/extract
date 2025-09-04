# Extract - Makefile
# SwiftUI macOS/iOS app for photo library export

.PHONY: help format build clean test run install-deps format-fix

# Default target
help:
	@echo "Extract - Available commands:"
	@echo "  make format      - Run SwiftFormat on source code"
	@echo "  make build       - Build the project (runs format first)"
	@echo "  make run         - Build and run the app"
	@echo "  make test        - Run unit tests"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make install-deps - Install SwiftFormat via Homebrew"

# Install dependencies
install-deps:
	@echo "Installing SwiftFormat..."
	@if ! which brew > /dev/null; then \
		echo "Error: Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi
	brew install swiftformat

# Run SwiftFormat
format:
	@echo "Running SwiftFormat..."
	swiftformat .

# Build the project (with formatting)
build: format
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

# Run tests
test: format
	@echo "Building main app with testing enabled..."
	xcodebuild -project extract.xcodeproj -target extract -configuration Debug build
	@echo "Building test target..."
	xcodebuild -project extract.xcodeproj -target extractTests -configuration Debug -destination 'platform=macOS' build
	@echo "Test target built successfully. Note: Use Xcode to run tests interactively."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	xcodebuild -project extract.xcodeproj -scheme extract clean
	rm -rf ~/Library/Developer/Xcode/DerivedData/extract-*

# Fix formatting issues automatically where possible
format-fix:
	@echo "Auto-fixing formatting issues..."
	swiftformat .