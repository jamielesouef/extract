#!/bin/bash
# Smart commit script for Extract project
# Analyzes git changes, runs tests/build, and creates intelligent commit messages

set -e

echo "🔍 Analyzing git changes..."

# Check if there are any changes
if git diff --cached --quiet && git diff --quiet; then
    echo "❌ No changes to commit."
    exit 0
fi

# Collect git information
echo "📊 Gathering git context..."
STATUS=$(git status --porcelain)
DIFF_STAGED=$(git diff --staged --stat)
RECENT_COMMITS=$(git log --oneline -5)

# Count changes
MODIFIED_FILES=$(echo "$STATUS" | wc -l | xargs)
STAGED_FILES=$(git diff --cached --name-only | wc -l | xargs)

echo "📁 Modified files: $MODIFIED_FILES"
echo "📋 Files to commit: $STAGED_FILES (if 0, will stage all)"

# Stage all changes if nothing is staged
if [ "$STAGED_FILES" -eq 0 ]; then
    echo "🔄 Staging all changes..."
    git add .
    DIFF_STAGED=$(git diff --staged --stat)
fi

# Analyze changes and create commit message
echo "💭 Analyzing changes to generate descriptive commit message..."

# Get detailed change information
CHANGED_FILES=$(git diff --cached --name-only)
ADDITIONS=$(git diff --cached --numstat | awk '{sum+=$1} END {print sum+0}')
DELETIONS=$(git diff --cached --numstat | awk '{sum+=$2} END {print sum+0}')
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | xargs)

# Analyze what was actually changed
CHANGES=()

# Check for new files
NEW_FILES=$(git diff --cached --name-status | grep "^A" | cut -f2)
if [ ! -z "$NEW_FILES" ]; then
    NEW_COUNT=$(echo "$NEW_FILES" | wc -l | xargs)
    if echo "$NEW_FILES" | grep -q "Test"; then
        CHANGES+=("Add $NEW_COUNT test files")
    elif echo "$NEW_FILES" | grep -q "View"; then
        CHANGES+=("Add new UI components")
    elif echo "$NEW_FILES" | grep -q "Service\|Store\|Protocol"; then
        CHANGES+=("Add new service layer")
    else
        CHANGES+=("Add $NEW_COUNT new files")
    fi
fi

# Check for script/build system changes
if echo "$CHANGED_FILES" | grep -q "scripts/\|Makefile\|\.sh"; then
    if git diff --cached | grep -q "CHANGES.*descriptive\|commit.*message\|git.*diff"; then
        CHANGES+=("enhance commit message generation in build scripts")
    elif git diff --cached | grep -q "swiftformat\|build\|test"; then
        CHANGES+=("update build automation scripts")
    else
        CHANGES+=("update build scripts")
    fi
fi

# Check for specific functionality changes
if echo "$CHANGED_FILES" | grep -q "PhotoAsset\|MockPhotoAsset"; then
    if echo "$NEW_FILES" | grep -q "PhotoAsset"; then
        CHANGES+=("implement PhotoAsset protocol abstraction")
    else
        CHANGES+=("update PhotoAsset protocol implementation")
    fi
fi

if echo "$CHANGED_FILES" | grep -q "MediaStore"; then
    if git diff --cached | grep -q "iso8601Formatter\|nonisolated"; then
        CHANGES+=("optimize MediaStore with static formatter")
    elif git diff --cached | grep -q "isInSelectMode"; then
        CHANGES+=("add selection mode to MediaStore")
    else
        CHANGES+=("update MediaStore functionality")
    fi
fi

if echo "$CHANGED_FILES" | grep -q "Selection\|Select"; then
    if echo "$NEW_FILES" | grep -q "Select"; then
        CHANGES+=("implement photo selection interface")
    else
        CHANGES+=("update photo selection functionality")
    fi
fi

if echo "$CHANGED_FILES" | grep -q "ImageThumbnailView"; then
    if git diff --cached | grep -q "overlay\|glassEffect"; then
        CHANGES+=("improve ImageThumbnailView with selection overlay")
    else
        CHANGES+=("update ImageThumbnailView")
    fi
fi

if echo "$CHANGED_FILES" | grep -q "Test.*\.swift"; then
    if git diff --cached | grep -q "@Test.*getCloudIdentifier"; then
        CHANGES+=("expand getCloudIdentifier test coverage")
    elif [ $ADDITIONS -gt $DELETIONS ]; then
        CHANGES+=("add comprehensive test cases")
    else
        CHANGES+=("update test suite")
    fi
fi

if echo "$CHANGED_FILES" | grep -q "swiftformat\|Makefile"; then
    CHANGES+=("update build configuration")
fi

if echo "$CHANGED_FILES" | grep -q "Constants"; then
    CHANGES+=("update UI constants and styling")
fi

if echo "$CHANGED_FILES" | grep -q "Preview"; then
    CHANGES+=("improve SwiftUI previews")
fi

# Generate commit message
if [ ${#CHANGES[@]} -eq 0 ]; then
    # Fallback for unrecognized changes
    if [ $FILE_COUNT -eq 1 ]; then
        FILENAME=$(basename "$CHANGED_FILES")
        COMMIT_MSG="Update ${FILENAME%.*}"
    else
        COMMIT_MSG="Update $FILE_COUNT files with various improvements"
    fi
else
    # Create descriptive message from changes
    if [ ${#CHANGES[@]} -eq 1 ]; then
        COMMIT_MSG="${CHANGES[0]^}"
    elif [ ${#CHANGES[@]} -eq 2 ]; then
        COMMIT_MSG="${CHANGES[0]^} and ${CHANGES[1]}"
    else
        # Join first n-1 with commas, last with "and"
        MAIN_CHANGES="${CHANGES[0]^}"
        for (( i=1; i<${#CHANGES[@]}-1; i++ )); do
            MAIN_CHANGES="$MAIN_CHANGES, ${CHANGES[i]}"
        done
        COMMIT_MSG="$MAIN_CHANGES, and ${CHANGES[-1]}"
    fi
fi

echo "🔍 Detected changes: ${CHANGES[*]}"

# Show preview
echo "📝 Proposed commit message: '$COMMIT_MSG'"
echo ""
echo "🔍 Files to be committed:"
git diff --cached --name-only | sed 's/^/  • /'
echo ""

# Run tests and build before committing
echo "🧪 Running tests and build verification..."
echo "⏳ This may take a moment..."

# Run SwiftFormat first
echo "🎨 Running SwiftFormat..."
if ! swiftformat . > /dev/null 2>&1; then
    echo "❌ SwiftFormat failed. Please fix formatting issues."
    exit 1
fi

# Check if SwiftFormat made any changes and stage them
if ! git diff --quiet; then
    echo "📝 SwiftFormat made formatting changes, staging them..."
    git add .
fi

# Build the project
echo "🔨 Building project..."
if ! xcodebuild -project extract.xcodeproj -target extract -configuration Debug build > /dev/null 2>&1; then
    echo "❌ Build failed. Please fix compilation errors before committing."
    echo "💡 Run 'make build' to see detailed error messages."
    exit 1
fi

# Build test target to verify tests compile
echo "🧪 Building test target..."
if ! xcodebuild -project extract.xcodeproj -target extractTests -configuration Debug -destination 'platform=macOS' build > /dev/null 2>&1; then
    echo "❌ Test target build failed. Please fix test compilation errors before committing."
    echo "💡 Run 'make test' to see detailed error messages."
    exit 1
fi

echo "✅ All checks passed! Build and tests are working."
echo ""

# Ask for confirmation
read -p "❓ Proceed with this commit? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Creating commit..."
    git commit -m "$COMMIT_MSG"
    echo "🎉 Commit created successfully!"
    echo "📊 Commit stats:"
    git show --stat HEAD
else
    echo "❌ Commit cancelled."
    exit 1
fi