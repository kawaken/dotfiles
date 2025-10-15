# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a personal dotfiles repository containing shell configurations, Git aliases, and custom tools. Key components:

- **zsh/**: Shell configuration with modular plugin system
  - `zsh/_zshenv`: Main environment setup that sets ZDOTDIR to load plugins
  - `zsh/plugins/`: Individual plugin files loaded automatically
- **git/**: Git configuration and custom commands
  - `git/.gitconfig`: Main Git configuration with aliases and delta integration
  - `git/bin/`: Custom Git commands (git-* scripts)
  - `git/rc/`: zsh functions sourced by the git plugin
- **claude/commands/**: Custom Claude Code commands
- **ghostty/**: Terminal emulator configuration

## Code Conventions

### Shell Scripting
- Use zsh, not bash (all scripts should start with `#!/usr/bin/env zsh`)
- No Perl usage
- Avoid PIPE with `while read` combinations
- Minimize `while` loop usage
- Use ripgrep (`rg`) for search operations instead of `find`/`grep`
- **Avoid reserved variables**: Do not use `status` as a variable name (it's a read-only special variable in zsh that holds the exit status of the last command)

### Plugin Structure
- New plugins go in `zsh/plugins/` as individual files
- Plugin names use underscores (e.g., `plugin_name`)
- Git-related functions go in `git/rc/` and are auto-sourced by git plugin

### Custom Git Commands
- Place in `git/bin/` with `git-` prefix
- Make executable and use zsh shebang
- Follow existing naming patterns
