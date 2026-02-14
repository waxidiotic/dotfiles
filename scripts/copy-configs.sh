#!/usr/bin/env bash

# copy-configs.sh
# Interactive script to copy dotfiles from repository to system locations
# Uses gum for interactive selection

set -e

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get the script's directory (repository root is parent)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PATHS_JSON="$REPO_DIR/paths.json"

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Error: Homebrew is not installed.${NC}"
        echo ""
        echo "Homebrew is required to auto-install dependencies."
        echo "Install it from: https://brew.sh"
        echo ""
        return 1
    fi
    return 0
}

# Install a tool using Homebrew
install_tool() {
    local tool="$1"
    echo ""
    echo -e "${YELLOW}Installing $tool...${NC}"
    if brew install "$tool"; then
        echo -e "${GREEN}✓${NC} $tool installed successfully"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to install $tool"
        return 1
    fi
}

# Dependency check with auto-install option
check_dependencies() {
    local missing_tools=()
    local tools_to_install=()

    # Check for gum
    if ! command -v gum &> /dev/null; then
        missing_tools+=("gum")
    fi

    # Check for jq
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    # If all dependencies are installed, we're done
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        return 0
    fi

    # Display missing tools
    echo -e "${YELLOW}The following required tools are not installed:${NC}"
    for tool in "${missing_tools[@]}"; do
        echo "  - $tool"
    done
    echo ""

    # Ask if user wants to auto-install
    read -p "Would you like to install them automatically? (Y/n) " -n 1 -r
    echo ""

    # Default to Yes if user just presses Enter (empty response)
    if [[ -z "$REPLY" ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if Homebrew is available
        if ! check_homebrew; then
            echo "Please install the missing tools manually and run this script again."
            exit 1
        fi

        # Install each missing tool
        for tool in "${missing_tools[@]}"; do
            if ! install_tool "$tool"; then
                echo -e "${RED}Installation failed. Please install $tool manually.${NC}"
                exit 1
            fi
        done

        echo ""
        echo -e "${GREEN}All dependencies installed successfully!${NC}"
        echo ""
    else
        echo ""
        echo "Please install the missing tools manually:"
        echo "  macOS:   brew install ${missing_tools[*]}"
        echo "  Linux:   Use your package manager"
        echo ""
        exit 1
    fi
}

# Map paths.json keys to source filenames in the repository
get_source_file() {
    case "$1" in
        ghostty) echo "ghostty_config" ;;
        zed) echo "zed_settings.json" ;;
        zsh) echo ".zshrc" ;;
        *) echo "" ;;
    esac
}

# Expand tilde to $HOME in paths
expand_path() {
    local path="$1"
    echo "${path/#\~/$HOME}"
}

# Main script logic
main() {
    echo ""
    gum style --border normal --padding "0 1" --border-foreground 212 "Dotfiles Configuration Copier"
    echo ""

    # Check dependencies
    check_dependencies

    # Check if paths.json exists
    if [[ ! -f "$PATHS_JSON" ]]; then
        echo -e "${RED}Error: paths.json not found at $PATHS_JSON${NC}"
        exit 1
    fi

    # Get available config keys from paths.json
    mapfile -t config_keys < <(jq -r 'keys[]' "$PATHS_JSON")

    if [[ ${#config_keys[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No configurations found in paths.json${NC}"
        exit 0
    fi

    # Let user select configs to copy
    echo "Select configurations to copy (use spacebar to select, enter to confirm):"
    echo ""

    selected_configs=$(printf '%s\n' "${config_keys[@]}" | gum choose --no-limit --header "")

    # Check if any configs were selected
    if [[ -z "$selected_configs" ]]; then
        echo ""
        echo -e "${YELLOW}No configurations selected. Exiting.${NC}"
        exit 0
    fi

    echo ""

    # Track statistics
    local copied_count=0
    local skipped_count=0
    local error_count=0

    # Process each selected config
    while IFS= read -r config_key; do
        # Get source filename and destination path
        source_file=$(get_source_file "$config_key")
        dest_path=$(jq -r --arg key "$config_key" '.[$key]' "$PATHS_JSON")

        # Validate source file mapping
        if [[ -z "$source_file" ]]; then
            echo -e "${RED}✗${NC} $config_key: Unknown config key (no source file mapping)"
            ((error_count++))
            continue
        fi

        source_path="$REPO_DIR/$source_file"
        dest_path=$(expand_path "$dest_path")

        # Check if source file exists
        if [[ ! -f "$source_path" ]]; then
            echo -e "${RED}✗${NC} $config_key: Source file not found: $source_file"
            ((error_count++))
            continue
        fi

        # Check if destination file exists
        if [[ -f "$dest_path" ]]; then
            echo -e "${YELLOW}⚠${NC}  $config_key: File already exists at $dest_path"
            if gum confirm "Overwrite existing file?"; then
                # Create parent directory if needed
                dest_dir=$(dirname "$dest_path")
                mkdir -p "$dest_dir"

                # Copy file
                if cp "$source_path" "$dest_path"; then
                    echo -e "${GREEN}✓${NC} $config_key: Copied to $dest_path"
                    ((copied_count++))
                else
                    echo -e "${RED}✗${NC} $config_key: Failed to copy file"
                    ((error_count++))
                fi
            else
                echo -e "${YELLOW}⊘${NC} $config_key: Skipped"
                ((skipped_count++))
            fi
        else
            # Create parent directory if needed
            dest_dir=$(dirname "$dest_path")
            mkdir -p "$dest_dir"

            # Copy file
            if cp "$source_path" "$dest_path"; then
                echo -e "${GREEN}✓${NC} $config_key: Copied to $dest_path"
                ((copied_count++))
            else
                echo -e "${RED}✗${NC} $config_key: Failed to copy file"
                ((error_count++))
            fi
        fi

        echo ""
    done <<< "$selected_configs"

    # Display summary
    echo ""
    gum style --border normal --padding "0 1" --border-foreground 212 "Summary"
    echo ""
    echo "  Copied:  $copied_count"
    echo "  Skipped: $skipped_count"
    echo "  Errors:  $error_count"
    echo ""
}

# Run main function
main "$@"
