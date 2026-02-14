# Dotfiles

Personal configuration files for development environment setup.

## Contents

This repository contains configuration files for:

- **Ghostty** - Terminal emulator with Catppuccin Mocha theme
- **Zed** - Code editor with Biome formatter and language servers
- **Zsh** - Shell with Oh My Zsh, Spaceship theme, and useful plugins

## Quick Start

### Copy Configurations to System

Use the interactive script to copy configuration files to their system locations:

```bash
./scripts/copy-configs.sh
```

The script will:
1. Check for required dependencies (`gum` and `jq`)
2. Offer to auto-install missing tools (defaults to Yes)
3. Present an interactive menu to select configs
4. Confirm before overwriting existing files
5. Copy selected files to their destinations

### Manual Installation

Configuration files are mapped in `paths.json`:

| Config | Source File | Destination |
|--------|-------------|-------------|
| Ghostty | `ghostty_config` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| Zed | `zed_settings.json` | `~/.config/zed/settings.json` |
| Zsh | `.zshrc` | `~/.zshrc` |

## Configuration Details

### Ghostty Terminal

- **Font**: Monaspace Argon (16pt)
- **Theme**: Catppuccin Mocha
- **Appearance**: Transparent background with blur effect
- **Shell Integration**: Zsh

### Zed Editor

- **Font**: Monaspace Argon (14pt for editor, 18pt for UI)
- **Theme**: Catppuccin Mocha (dark) / Catppuccin Latte (light)
- **Formatter**: Biome for JavaScript, TypeScript, JSON, and CSS
- **Keymap**: VSCode
- **AI Agent**: Claude Sonnet

### Zsh Shell

- **Framework**: Oh My Zsh
- **Theme**: Spaceship (async disabled)
- **Plugins**:
  - `gh` - GitHub CLI integration
  - `git` - Git aliases and completions
  - `macos` - macOS-specific aliases
  - `npm` - NPM completions
  - `you-should-use` - Reminds you of existing aliases
  - `zsh-autosuggestions` - Fish-like autosuggestions
  - `zsh-bat` - Better `cat` with syntax highlighting
  - `zsh-syntax-highlighting` - Command syntax highlighting

- **Development Tools**:
  - Node Version Manager (nvm)
  - pnpm
  - Bun
  - mise (runtime version manager)
  - PostgreSQL 17
  - Ruby (Homebrew)

- **Default Editor**: Zed (`zed --wait`)

## Dependencies

### Required for Copy Script

- [gum](https://github.com/charmbracelet/gum) - Interactive CLI tool
- [jq](https://jqlang.github.io/jq/) - JSON processor

Both can be installed automatically by the script, or manually:

```bash
brew install gum jq
```

### Required for Zsh Config

- [Oh My Zsh](https://ohmyz.sh/)
- [Spaceship Prompt](https://spaceship-prompt.sh/)
- Zsh plugins (install via Oh My Zsh or manually)

### Optional Tools

- [Homebrew](https://brew.sh/) - Package manager for macOS
- [nvm](https://github.com/nvm-sh/nvm) - Node version manager
- [mise](https://mise.jdx.dev/) - Runtime version manager
- [Monaspace](https://monaspace.githubnext.com/) - Font family

## Repository Structure

```
.
├── README.md              # This file
├── paths.json             # Maps config keys to system paths
├── ghostty_config         # Ghostty terminal configuration
├── zed_settings.json      # Zed editor settings
├── .zshrc                 # Zsh shell configuration
├── scripts/
│   └── copy-configs.sh    # Interactive copy script
└── backups/               # For storing backups (empty)
```

## Adding New Configurations

1. Add the config file to the repository root
2. Update `paths.json` with the new mapping:
   ```json
   {
     "app-name": "~/path/to/config/file"
   }
   ```
3. Update `get_source_file()` function in `scripts/copy-configs.sh`:
   ```bash
   app-name) echo "filename_in_repo" ;;
   ```

## License

Personal configuration files. Feel free to use as reference or inspiration for your own setup.
