# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common Commands

- **Build the project:**
  ```bash
  xcodebuild -scheme "extract" -configuration Release
  ```

- **Run tests:**
  ```bash
  xcodebuild test -scheme "extract" -destination 'platform=iOS Simulator,name=iPhone 14'
  ```

- **Lint the code:**
  
  If a specific linter is set up, use the following command:
  ```bash
  swiftlint
  ```
  Ensure SwiftLint is installed and configured correctly in your project.

## Code Architecture

- The project uses **Xcode** for building and management.
- The configurations include settings for running on **iOS simulators** and **macOS**, indicating a cross-platform compatibility.
- The project deploys with security enhancements like **Hardened Runtime** and **App Sandbox**, ensuring secure operations.
- Swift concurrency is approached with a focus on performance using configurations like `SWIFT_APPROACHABLE_CONCURRENCY`.

When working in this repository, it is important to ensure that the environment is consistent with Xcode’s settings for both Debug and Release configurations. This allows efficient operation and testing. 

Future instances handling this codebase should ensure they have Xcode and necessary dependencies installed and properly configured.
