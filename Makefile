# Extract - Makefile
# SwiftUI macOS/iOS app for photo library export

.PHONY: help lint build clean test run install-deps

# Default target
help:
	@echo "Extract - Available commands:"
	@echo "  make lint        - Run SwiftLint on source code"
	@echo "  make build       - Build the project (runs lint first)"
	@echo "  make run         - Build and run the app"
	@echo "  make test        - Run unit tests"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make install-deps - Install SwiftLint via Homebrew"

# Check if SwiftLint is installed
check-swiftlint:
	@if ! which swiftlint > /dev/null; then \
		echo "Error: SwiftLint not found. Run 'make install-deps' first."; \
		exit 1; \
	fi

# Install dependencies
install-deps:
	@echo "Installing SwiftLint..."
	@if ! which brew > /dev/null; then \
		echo "Error: Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi
	brew install swiftlint

# Run SwiftLint
lint: check-swiftlint
	@echo "Running SwiftLint..."
	swiftlint

# Build the project (with linting)
build: lint
	@echo "Building Extract..."
	xcodebuild -project extract.xcodeproj -scheme extract -configuration Debug build

# Build for release
release: lint
	@echo "Building Extract for Release..."
	xcodebuild -project extract.xcodeproj -scheme extract -configuration Release build

# Build and run the app
run: build
	@echo "Launching Extract..."
	open /Users/jamielesouef/Library/Developer/Xcode/DerivedData/extract-*/Build/Products/Debug/extract.app

# Run tests
test: lint
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

# Fix SwiftLint issues automatically where possible
lint-fix: check-swiftlint
	@echo "Auto-fixing SwiftLint issues..."
	swiftlint --fix