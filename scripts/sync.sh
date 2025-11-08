#!/bin/bash

# Bidirectional sync dotfiles between repository and Cursor installation directories
set -euo pipefail

# Get the repository root directory (parent of scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to get Cursor path for a repo file
get_cursor_path() {
    local repo_file="$1"
    case "$repo_file" in
        "settings.json")
            echo "$HOME/Library/Application Support/Cursor/User/settings.json"
            ;;
        "extensions.json")
            echo "$HOME/.cursor/extensions/extensions.json"
            ;;
        *)
            echo ""
            ;;
    esac
}

# List of files to sync
FILES=("settings.json" "extensions.json")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show direction selection menu
show_direction_menu() {
    echo ""
    echo "Select sync direction:"
    echo "  1) Sync TO Cursor (from repository)"
    echo "  2) Sync FROM Cursor (to repository)"
    echo ""
}

# Function to display available files menu
show_file_menu() {
    local direction="$1"
    shift  # Remove first argument (direction)
    local files=("$@")
    
    echo ""
    if [[ "$direction" == "to_cursor" ]]; then
        echo "Available files to sync TO Cursor:"
    else
        echo "Available files to sync FROM Cursor:"
    fi
    
    local i=1
    if [[ ${#files[@]} -gt 0 ]]; then
        for file in "${files[@]}"; do
            echo "  $i) $file"
            ((i++))
        done
    fi
    echo "  $i) All files"
    echo ""
}

# Function to validate target directory exists
validate_target_directory() {
    local dest_path="$1"
    local dest_dir="$(dirname "$dest_path")"
    
    if [[ ! -d "$dest_dir" ]]; then
        echo -e "${RED}Error: Target directory does not exist: $dest_dir${NC}" >&2
        if [[ "$dest_dir" == *"Cursor"* ]]; then
            echo "Please ensure Cursor is installed and the directory exists." >&2
        fi
        exit 1
    fi
}

# Function to get date string in YYYYMMDD format
get_date_string() {
    date +"%Y%m%d"
}

# Function to sync FROM repository TO Cursor
sync_to_cursor() {
    local source_file="$1"
    local dest_path="$(get_cursor_path "$source_file")"
    
    if [[ -z "$dest_path" ]]; then
        echo -e "${RED}Error: Unknown file: $source_file${NC}" >&2
        return 1
    fi
    
    # Check if source file exists in repo
    if [[ ! -f "$REPO_ROOT/$source_file" ]]; then
        echo -e "${RED}Error: Source file not found: $REPO_ROOT/$source_file${NC}" >&2
        return 1
    fi
    
    # Validate target directory exists
    validate_target_directory "$dest_path"
    
    # Check if destination file exists and ask for confirmation
    if [[ -f "$dest_path" ]]; then
        echo -e "${YELLOW}Warning: Destination file already exists: $dest_path${NC}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Skipping $source_file${NC}"
            return 0
        fi
    fi
    
    # Copy the file
    if cp "$REPO_ROOT/$source_file" "$dest_path"; then
        echo -e "${GREEN}✓ Synced $source_file → $dest_path${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to sync $source_file${NC}" >&2
        return 1
    fi
}

# Function to sync FROM Cursor TO repository
sync_from_cursor() {
    local dest_file="$1"
    local source_path="$(get_cursor_path "$dest_file")"
    local dest_path="$REPO_ROOT/$dest_file"
    
    if [[ -z "$source_path" ]]; then
        echo -e "${RED}Error: Unknown file: $dest_file${NC}" >&2
        return 1
    fi
    
    # Check if source file exists in Cursor directory
    if [[ ! -f "$source_path" ]]; then
        echo -e "${RED}Error: Source file not found in Cursor: $source_path${NC}" >&2
        return 1
    fi
    
    # Validate target directory exists (repo root)
    if [[ ! -d "$REPO_ROOT" ]]; then
        echo -e "${RED}Error: Repository directory does not exist: $REPO_ROOT${NC}" >&2
        exit 1
    fi
    
    # Create backup if repo file exists
    if [[ -f "$dest_path" ]]; then
        # Extract filename without extension for backup directory name
        local backup_dir_name="${dest_file%.*}"
        local backup_dir="$REPO_ROOT/backups/$backup_dir_name"
        local date_string="$(get_date_string)"
        local backup_file="$backup_dir/${backup_dir_name}_${date_string}.json"
        
        # Create backup directory if it doesn't exist
        mkdir -p "$backup_dir"
        
        # Create backup
        if cp "$dest_path" "$backup_file"; then
            echo -e "${BLUE}ℹ Backed up existing $dest_file to $backup_file${NC}"
        else
            echo -e "${RED}Error: Failed to create backup${NC}" >&2
            return 1
        fi
    fi
    
    # Copy the file from Cursor to repo (always overwrite)
    if cp "$source_path" "$dest_path"; then
        echo -e "${GREEN}✓ Synced $source_path → $dest_path${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to sync $dest_file${NC}" >&2
        return 1
    fi
}

# Function to get available files based on direction
get_available_files() {
    local direction="$1"
    local files=()
    
    for file in "${FILES[@]}"; do
        if [[ "$direction" == "to_cursor" ]]; then
            # Check if file exists in repo
            if [[ -f "$REPO_ROOT/$file" ]]; then
                files+=("$file")
            fi
        else
            # Check if file exists in Cursor directory
            local cursor_path="$(get_cursor_path "$file")"
            if [[ -n "$cursor_path" ]] && [[ -f "$cursor_path" ]]; then
                files+=("$file")
            fi
        fi
    done
    
    echo "${files[@]}"
}

# Main execution
main() {
    echo "Dotfiles Sync Tool (Bidirectional)"
    echo "Repository: $REPO_ROOT"
    
    # Show direction menu and get selection
    show_direction_menu
    read -p "Select direction (1-2): " direction_selection
    
    # Validate direction selection
    if ! [[ "$direction_selection" =~ ^[12]$ ]]; then
        echo -e "${RED}Error: Invalid selection${NC}" >&2
        exit 1
    fi
    
    # Determine sync direction
    local direction=""
    if [[ $direction_selection -eq 1 ]]; then
        direction="to_cursor"
    else
        direction="from_cursor"
    fi
    
    # Get available files for selected direction
    local available_files_str="$(get_available_files "$direction")"
    local available_files=()
    if [[ -n "$available_files_str" ]]; then
        read -a available_files <<< "$available_files_str"
    fi
    
    if [[ ${#available_files[@]} -eq 0 ]]; then
        if [[ "$direction" == "to_cursor" ]]; then
            echo -e "${RED}Error: No files found to sync in repository root${NC}" >&2
        else
            echo -e "${RED}Error: No files found to sync in Cursor directories${NC}" >&2
        fi
        exit 1
    fi
    
    # Show file menu and get user selection
    show_file_menu "$direction" "${available_files[@]}"
    
    read -p "Select file to sync (1-$((${#available_files[@]} + 1))): " file_selection
    
    # Validate file selection
    if ! [[ "$file_selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid selection${NC}" >&2
        exit 1
    fi
    
    local max_option=$((${#available_files[@]} + 1))
    if [[ $file_selection -lt 1 ]] || [[ $file_selection -gt $max_option ]]; then
        echo -e "${RED}Error: Selection out of range${NC}" >&2
        exit 1
    fi
    
    # Process selection
    local success_count=0
    local total_count=0
    
    if [[ $file_selection -eq $max_option ]]; then
        # Sync all files
        echo ""
        if [[ "$direction" == "to_cursor" ]]; then
            echo "Syncing all files TO Cursor..."
        else
            echo "Syncing all files FROM Cursor..."
        fi
        
        for file in "${available_files[@]}"; do
            ((total_count++))
            if [[ "$direction" == "to_cursor" ]]; then
                if sync_to_cursor "$file"; then
                    ((success_count++))
                fi
            else
                if sync_from_cursor "$file"; then
                    ((success_count++))
                fi
            fi
        done
    else
        # Sync selected file
        local selected_file="${available_files[$((file_selection - 1))]}"
        total_count=1
        if [[ "$direction" == "to_cursor" ]]; then
            if sync_to_cursor "$selected_file"; then
                success_count=1
            fi
        else
            if sync_from_cursor "$selected_file"; then
                success_count=1
            fi
        fi
    fi
    
    # Summary
    echo ""
    if [[ $success_count -eq $total_count ]]; then
        echo -e "${GREEN}Successfully synced $success_count file(s)${NC}"
        exit 0
    else
        echo -e "${RED}Synced $success_count of $total_count file(s)${NC}" >&2
        exit 1
    fi
}

# Run main function
main
