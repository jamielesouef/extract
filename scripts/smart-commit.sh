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
echo "💭 Generating commit message..."

# Simple heuristics for commit message generation
COMMIT_MSG=""

# Check file types and changes
if echo "$DIFF_STAGED" | grep -q "Test"; then
    COMMIT_TYPE="test"
elif echo "$DIFF_STAGED" | grep -q "View\|UI\|SwiftUI"; then
    COMMIT_TYPE="ui"
elif echo "$DIFF_STAGED" | grep -q "Service\|Store\|Protocol"; then
    COMMIT_TYPE="service"
elif echo "$DIFF_STAGED" | grep -q "Model"; then
    COMMIT_TYPE="model"
else
    COMMIT_TYPE="feature"
fi

# Generate message based on type and files
case $COMMIT_TYPE in
    "test")
        COMMIT_MSG="Update tests and improve coverage"
        ;;
    "ui")
        COMMIT_MSG="Update UI components and views"
        ;;
    "service")
        COMMIT_MSG="Update services and data layer"
        ;;
    "model")
        COMMIT_MSG="Update data models and protocols"
        ;;
    *)
        COMMIT_MSG="Update project files"
        ;;
esac

# Enhance message based on specific changes
if echo "$DIFF_STAGED" | grep -q "PhotoAsset\|MediaStore"; then
    COMMIT_MSG="Update photo asset handling and media store"
elif echo "$DIFF_STAGED" | grep -q "Selection\|Select"; then
    COMMIT_MSG="Update photo selection functionality"
elif echo "$DIFF_STAGED" | grep -q "Format\|Swift"; then
    COMMIT_MSG="Update code formatting and configuration"
elif echo "$DIFF_STAGED" | grep -q "Preview\|Debug"; then
    COMMIT_MSG="Update previews and debug components"
fi

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