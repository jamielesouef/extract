#!/bin/bash
# Smart commit script for Extract project
# Analyzes git changes, runs tests/build, and creates intelligent commit messages

set -e

# Parse command line arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--yes|-y] [--help|-h]"
            echo "  --yes, -y    Automatically proceed without confirmation"
            echo "  --help, -h   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

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

# Analyse file types
SWIFT_FILES=$(echo "$CHANGED_FILES" | grep -c "\.swift$" 2>/dev/null || echo "0")
TEST_FILES=$(echo "$CHANGED_FILES" | grep -c "Tests\.swift$" 2>/dev/null || echo "0")
CONFIG_FILES=$(echo "$CHANGED_FILES" | grep -E "\.(json|plist|xcodeproj|pbxproj|md|yml|yaml)$" 2>/dev/null | wc -l || echo "0")
RESOURCE_FILES=$(echo "$CHANGED_FILES" | grep -E "\.(png|jpg|jpeg|gif|svg|pdf|xcassets)$" 2>/dev/null | wc -l || echo "0")

# Calculate percentages
if [ "$FILE_COUNT" -gt 0 ]; then
    SWIFT_PCT=$((SWIFT_FILES * 100 / FILE_COUNT))
    TEST_PCT=$((TEST_FILES * 100 / FILE_COUNT))
else
    SWIFT_PCT=0
    TEST_PCT=0
fi

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
        LAST_INDEX=$((${#CHANGES[@]} - 1))
        COMMIT_MSG="$MAIN_CHANGES, and ${CHANGES[$LAST_INDEX]}"
    fi
fi

echo "🔍 Detected changes: ${CHANGES[*]}"

# Create detailed commit body with statistics
COMMIT_BODY=""
COMMIT_BODY="$COMMIT_BODY"$'\n'"📊 Change Statistics:"
COMMIT_BODY="$COMMIT_BODY"$'\n'"- Files: $FILE_COUNT modified"
COMMIT_BODY="$COMMIT_BODY"$'\n'"- Lines: +$ADDITIONS/-$DELETIONS"

if [ "$SWIFT_FILES" -gt 0 ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"- Swift: $SWIFT_FILES files ($SWIFT_PCT%)"
fi

if [ "$TEST_FILES" -gt 0 ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"- Tests: $TEST_FILES files ($TEST_PCT%)"
fi

if [ "$CONFIG_FILES" -gt 0 ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"- Config: $CONFIG_FILES files"
fi

if [ "$RESOURCE_FILES" -gt 0 ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"- Resources: $RESOURCE_FILES files"
fi

# Add file breakdown by category
COMMIT_BODY="$COMMIT_BODY"$'\n'$'\n'"📁 Modified Files by Type:"

# Add Swift files (excluding tests)
SWIFT_LIST=$(echo "$CHANGED_FILES" | grep "\.swift$" 2>/dev/null | grep -v "Tests\.swift$" 2>/dev/null || echo "")
if [ ! -z "$SWIFT_LIST" ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"  Swift:"
    for file in $SWIFT_LIST; do
        COMMIT_BODY="$COMMIT_BODY"$'\n'"    • $file"
    done
fi

# Add test files
TEST_LIST=$(echo "$CHANGED_FILES" | grep "Tests\.swift$" 2>/dev/null || echo "")
if [ ! -z "$TEST_LIST" ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"  Tests:"
    for file in $TEST_LIST; do
        COMMIT_BODY="$COMMIT_BODY"$'\n'"    • $file"
    done
fi

# Add configuration files
CONFIG_LIST=$(echo "$CHANGED_FILES" | grep -E "\.(json|plist|xcodeproj|pbxproj|md|yml|yaml)$" 2>/dev/null || echo "")
if [ ! -z "$CONFIG_LIST" ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"  Config:"
    for file in $CONFIG_LIST; do
        COMMIT_BODY="$COMMIT_BODY"$'\n'"    • $file"
    done
fi

# Add resource files
RESOURCE_LIST=$(echo "$CHANGED_FILES" | grep -E "\.(png|jpg|jpeg|gif|svg|pdf|xcassets)$" 2>/dev/null || echo "")
if [ ! -z "$RESOURCE_LIST" ]; then
    COMMIT_BODY="$COMMIT_BODY"$'\n'"  Resources:"
    for file in $RESOURCE_LIST; do
        COMMIT_BODY="$COMMIT_BODY"$'\n'"    • $file"
    done
fi

# Create full commit message with body
FULL_COMMIT_MSG="$COMMIT_MSG$COMMIT_BODY"

# Show preview with enhanced details
echo ""
echo "📝 Proposed commit message:"
echo "┌─ TITLE ─────────────────────────────────────────────────┐"
echo "│ $COMMIT_MSG"
echo "└─────────────────────────────────────────────────────────┘"
echo ""
echo "📊 Commit details preview:"
echo "   Files changed: $FILE_COUNT"
echo "   Lines changed: +$ADDITIONS/-$DELETIONS"
if [ "$SWIFT_FILES" -gt 0 ]; then
    echo "   Swift files: $SWIFT_FILES ($SWIFT_PCT%)"
fi
if [ "$TEST_FILES" -gt 0 ]; then
    echo "   Test files: $TEST_FILES ($TEST_PCT%)"
fi
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

# Ask for confirmation (unless auto-yes is enabled)
if [ "$AUTO_YES" = true ]; then
    echo "✅ Auto-proceeding with commit (--yes flag enabled)..."
    PROCEED=true
else
    read -p "❓ Proceed with this commit? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PROCEED=true
    else
        PROCEED=false
    fi
fi

if [ "$PROCEED" = true ]; then
    echo "✅ Creating commit..."
    
    # Create commit with detailed body
    git commit -m "$(cat <<EOF
$COMMIT_MSG$COMMIT_BODY

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
    
    echo "🎉 Commit created successfully!"
    echo "📊 Commit stats:"
    git show --stat HEAD
    echo ""
    echo "📝 Full commit message:"
    git show --format=full -s HEAD
else
    echo "❌ Commit cancelled."
    exit 1
fi