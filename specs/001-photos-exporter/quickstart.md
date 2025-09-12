# Photos Exporter Quickstart Guide

This guide walks through the essential user flows to validate the Photos Exporter implementation.

## Prerequisites

- iOS 18+ / iPadOS 18+ / macOS 26+ device
- Photos library with at least 10 photos/videos
- Network connectivity for S3/NAS testing
- External storage for folder exports (macOS)

## Test Scenario 1: Basic Local Export

**Goal**: Export 5 photos to a local folder

### Steps
1. Launch Photos Exporter app
2. Grant Photos library access when prompted
3. Navigate to "Browse Photos" section
4. Select 5 photos from different dates/albums
5. Tap "Export" button
6. Choose "Local Folder" as destination
7. Select destination folder (use document picker on iOS/iPadOS)
8. Configure export options:
   - Include originals: ✓
   - Include edited versions: ✗
   - Verification: SHA-256
   - Conflict resolution: Skip existing
9. Review export summary showing count and estimated size
10. Start export job
11. Monitor progress in real-time
12. Verify completion notification
13. Check destination folder for exported files
14. Verify file names match original assets
15. Confirm checksums match (if verification enabled)

### Expected Results
- All 5 photos exported successfully
- Original filenames preserved or follow naming pattern
- No duplicate files created
- Progress reporting accurate
- Export completes within reasonable time (< 30 seconds for typical photos)
- Job shows "Completed" status in job list

## Test Scenario 2: S3 Export with Progress Monitoring

**Goal**: Export 20 mixed photos/videos to S3 storage

### Setup
- Configure S3 archive with test bucket credentials
- Ensure bucket has write permissions and sufficient space

### Steps
1. Navigate to "Archives" section
2. Tap "Add Archive"
3. Select "Amazon S3" type
4. Configure S3 settings:
   - Bucket name: `test-photos-export`
   - Region: `us-west-2`
   - Access key and secret key
   - Path prefix: `exports/test/`
5. Test connection - should show "Connected" status
6. Save archive configuration
7. Return to photo browser
8. Use smart filter to select:
   - Media type: Photos and Videos
   - Date range: Last 30 days
   - Include Live Photos: ✓
   - Count limit: 20 items
9. Create export job to S3 archive
10. Configure advanced options:
   - Folder structure: Date hierarchy (YYYY/MM/DD/)
   - Include metadata sidecars: JSON format
   - Multipart uploads for videos: ✓
   - Max concurrent transfers: 3
11. Start export and monitor:
    - Real-time progress percentage
    - Transfer rate (MB/s)
    - ETA updates
    - Per-item status
12. Test pause/resume functionality
13. Verify completion and integrity checks
14. Check S3 bucket contents match expected structure

### Expected Results
- Archive connection test passes
- All 20 items export successfully
- Folder structure follows date hierarchy
- Large videos use multipart upload
- Transfer rate achieves 5+ MB/s on good connection
- Pause/resume works without data loss
- All files pass integrity verification
- JSON metadata sidecars created for each asset

## Test Scenario 3: NAS Export with Error Recovery

**Goal**: Test robustness with network interruptions

### Setup
- Configure SMB or WebDAV archive pointing to NAS device
- Prepare to simulate network interruption

### Steps
1. Create NAS archive configuration:
   - Server: `192.168.1.100` (example NAS IP)
   - Protocol: SMB
   - Username/password for NAS access
   - Share path: `/PhotoBackups/`
2. Test connection - verify credentials work
3. Select 50 photos/videos for export
4. Start export job with:
   - Network: WiFi only
   - Retry policy: 3 attempts with exponential backoff
   - Checkpoint every 10 files
5. Let export run for ~25% completion
6. Simulate network interruption:
   - Disconnect WiFi for 30 seconds
   - Or temporarily block NAS IP in router
7. Observe error handling and retry behaviour
8. Restore network connectivity
9. Verify export resumes from checkpoint
10. Complete full export
11. Run archive audit to verify all files

### Expected Results
- NAS connection established successfully
- Export progresses normally initially
- Network interruption triggers retry logic
- Export pauses with appropriate error messages
- Automatic resume when network restored
- No duplicate files created during retry
- All files successfully transferred and verified
- Audit report shows 100% integrity

## Test Scenario 4: Large Library Performance

**Goal**: Validate performance with 1000+ photos

### Setup
- Photos library with 1000+ photos (mix of formats)
- Local destination with sufficient space (10+ GB)

### Steps
1. Use "All Photos" selection mode
2. Apply filter for specific year with many photos
3. Estimate should show 1000+ items and total size
4. Configure export for performance:
   - Skip metadata sidecars for speed
   - Use flat folder structure
   - Maximum concurrency: 6 threads
   - Verification: Size only (not full checksum)
5. Start export and monitor system resources
6. Track performance metrics:
   - Photos processed per second
   - Memory usage stability
   - CPU usage reasonable
   - No thermal throttling warnings
7. Verify export can complete without crashes
8. Spot-check random files for integrity
9. Confirm final counts match expectations

### Expected Results
- Asset enumeration completes in < 30 seconds
- Sustained processing rate of 5+ photos/second
- Memory usage remains stable (< 1GB)
- No app crashes or memory warnings
- All 1000+ photos exported successfully
- Final count matches initial estimate
- Spot-check files have correct content

## Test Scenario 5: Background Processing (iOS/iPadOS)

**Goal**: Validate background export functionality

### Steps
1. Start large export job (100+ photos to S3)
2. Configure job for background processing:
   - Requires WiFi: ✓
   - Requires power: ✓
   - Background processing: ✓
3. Start export and let it run for 30% completion
4. Put app in background (home button/swipe up)
5. Wait 2-3 minutes - system should continue processing
6. Return to app and check progress
7. Put device to sleep for 10 minutes
8. Wake device and check job status
9. Plug/unplug power to test power requirements
10. Switch to cellular to test WiFi requirement
11. Verify appropriate pause/resume behaviour

### Expected Results
- Export continues in background for reasonable time
- Progress advances while app backgrounded
- Job pauses when requirements not met (no power/WiFi)
- Job resumes when requirements restored
- Background processing notification appears
- No data corruption from background/foreground transitions

## Test Scenario 6: Audit and Repair

**Goal**: Validate integrity monitoring and repair capabilities

### Setup
- Completed export job with 50+ files
- Access to destination storage for file manipulation

### Steps
1. Navigate to completed export job
2. Run "Audit Archive" on the destination
3. Verify initial audit shows 100% integrity
4. Manually corrupt/delete some files in destination:
   - Delete 2-3 files completely
   - Modify contents of 2-3 files (add/remove bytes)
   - Rename 1-2 files
5. Run audit again - should detect issues
6. Review audit report showing:
   - Missing files
   - Corrupted files (checksum mismatch)  
   - Unexpected files
7. Generate repair plan from audit results
8. Review repair actions:
   - Re-export missing files
   - Re-upload corrupted files
   - Clean up unexpected files
9. Execute repair plan
10. Monitor repair progress
11. Run final audit to confirm 100% integrity restored

### Expected Results
- Initial audit completes successfully 
- File manipulations detected accurately in second audit
- Audit report clearly categorizes issues
- Repair plan covers all detected problems
- Repair execution fixes all issues
- Final audit confirms perfect integrity
- Repair process doesn't affect good files

## Performance Benchmarks

### Minimum Acceptable Performance
- Photo enumeration: 1000 photos/second
- Local export: 20 photos/second (average 5MB photos)
- S3 export: 5 MB/s sustained throughput
- NAS export: 15 MB/s on gigabit LAN
- Memory usage: < 1GB for 10,000 photo library
- CPU usage: < 50% average during active export

### Target Performance Goals
- Photo enumeration: 5000+ photos/second
- Local export: 40+ photos/second
- S3 export: 20+ MB/s sustained throughput  
- NAS export: 50+ MB/s on gigabit LAN
- Memory usage: < 500MB for 10,000 photo library
- CPU usage: < 30% average during active export

## Error Scenarios to Test

1. **Photos Access Denied**: Verify graceful handling and user guidance
2. **Network Timeout**: Ensure retry logic works correctly
3. **Insufficient Storage**: Clear error messages and prevention
4. **Authentication Failure**: Proper error reporting for archive access
5. **File Corruption**: Detection and handling during transfer
6. **App Termination**: Job state preservation and resume capability
7. **Low Memory**: Graceful degradation without crashes
8. **Thermal Throttling**: Automatic concurrency reduction

Each error scenario should result in clear user messaging and appropriate fallback behaviour without data loss or corruption.
