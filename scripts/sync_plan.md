# Bidirectional sync CLI script for dotfiles

## Overview
Enhance the existing sync.sh script to support bidirectional syncing:
- **Forward sync**: FROM repository TO Cursor installation directories (with overwrite confirmation)
- **Reverse sync**: FROM Cursor installation directories BACK TO repository (with automatic backups)

## Implementation Details

### Script Structure
- Main menu to select sync direction (TO Cursor or FROM Cursor)
- File selection menu for choosing which files to sync
- Two sync functions: `sync_to_cursor()` and `sync_from_cursor()`
- Backup system for reverse sync operations

### Key Features

1. **Direction Selection**: Main menu with options:
   - "Sync TO Cursor" (repo → Cursor)
   - "Sync FROM Cursor" (Cursor → repo)

2. **Forward Sync (TO Cursor)**:
   - Check if source file exists in repo
   - Validate Cursor target directory exists
   - Ask for confirmation before overwriting existing Cursor files
   - Copy file from repo to Cursor directory

3. **Reverse Sync (FROM Cursor)**:
   - Check if source file exists in Cursor directory
   - Validate repo target directory exists
   - Create backup directory if needed: `backups/{filename}/` (e.g., `backups/settings/`, `backups/extensions/`)
   - Backup existing repo file with date suffix: `{filename}_{YYYYMMDD}.json` (e.g., `settings_20251108.json`)
   - Always overwrite repo file (backup is automatic)

4. **File Discovery**: Detect available files based on sync direction
5. **Error Handling**: Validate directories, check source files, handle failures gracefully
6. **User Feedback**: Color-coded output showing sync status and backup locations

### Confirmed Requirements
- **Date Format**: YYYYMMDD (8 digits, e.g., 20251108)
- **Reverse Sync**: Always overwrite repo files (automatic backup)
- **Backup Location**: `backups/settings/` and `backups/extensions/` subdirectories
- **Backup Filename**: `{filename}_{YYYYMMDD}.json` (e.g., `settings_20251108.json`)
- **Forward Sync**: Ask for confirmation before overwriting existing Cursor files
- **Directory Validation**: Exit with error if target directories don't exist
- **Direction Selection**: Main menu with "Sync TO Cursor" or "Sync FROM Cursor" options

### File Mappings
- `settings.json` ↔ `~/Library/Application Support/Cursor/User/settings.json`
- `extensions.json` ↔ `~/.cursor/extensions/extensions.json`

## Files to Modify
- `scripts/sync.sh` - Enhance existing script with bidirectional sync and backup functionality

## Implementation Steps
1. Add direction selection menu function
2. Refactor existing `sync_file()` into `sync_to_cursor()` function
3. Create `sync_from_cursor()` function with backup logic:
   - Generate date string in YYYYMMDD format
   - Create backup directory structure
   - Backup existing repo file
   - Copy from Cursor to repo
4. Update `show_menu()` to work for both directions
5. Update `get_available_files()` to check appropriate source location
6. Refactor `main()` to handle direction selection first, then file selection

