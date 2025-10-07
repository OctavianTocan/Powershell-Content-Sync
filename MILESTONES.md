# Bash Script Development Milestones

## Project Goal

Convert `sync-assets.ps1` (PowerShell) to `sync-assets.sh` (Bash) for Ubuntu/WSL2 usage.

---

## ✅ Milestone 1: Basic Script Structure (COMPLETED)

**Objectives:**

- Set up shebang and error handling (`set -e`)
- Parse command-line arguments (`--resync`, `--dry-run`)
- Load and parse `.env` configuration file
- Skip comments and blank lines
- Extract KEY=VALUE pairs and create variables dynamically

**What We Learned:**

- Shebang: `#!/usr/bin/env bash`
- Script directory detection: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Argument parsing with `case/esac`
- File reading: `while IFS= read -r line; do ... done < "$FILE"`
- String manipulation: `${var%%pattern}` and `${var#pattern}`
- Regex matching: `[[ $var =~ pattern ]]`
- Glob patterns: `[[ $var == *substring* ]]`
- Dynamic variable creation: `declare "$key=$value"`

**Files Modified:**

- Created: `sync-assets.sh`
- Referenced: `.env`

---

## 🔲 Milestone 2: Dependency Checking (NEXT)

**Objectives:**

- Check if `rclone` is installed on the system
- Detect if package is available via `which` or `command -v`
- Offer to install rclone via `apt-get` (Ubuntu/Debian)
- Handle installation with user confirmation
- Verify installation succeeded

**Key Differences from PowerShell:**

- PowerShell: `Get-Command rclone`, `winget install`
- Bash: `command -v rclone`, `apt-get install`

**What We'll Learn:**

- Command existence checking
- Package management on Linux
- User input with `read`
- Exit codes and error handling

---

## 🔲 Milestone 3: Path Validation

**Objectives:**

- Check if rclone config file exists at `$RCLONE_CONFIG_PATH`
- Verify the config file is readable
- Create destination directory if it doesn't exist (`mkdir -p`)
- Validate that required environment variables are set

**What We'll Learn:**

- File existence checks: `[ -f "$file" ]`
- Directory checks: `[ -d "$dir" ]`
- Directory creation: `mkdir -p`
- Variable validation

---

## 🔲 Milestone 4: Execute rclone bisync

**Objectives:**

- Build the rclone command with all arguments from `.env`
- Construct array of arguments (bash equivalent of PowerShell arrays)
- Execute rclone bisync
- Capture and check exit codes
- Report success/failure with appropriate messages

**Key Challenges:**

- Bash array syntax
- Conditional argument addition (for `--resync`, `--dry-run`)
- Exit code handling
- Multi-line command construction

**What We'll Learn:**

- Bash arrays: `args=()`, `args+=("item")`
- Conditional logic with arrays
- Command execution and exit codes
- `$?` for last command exit code

---

## 🔲 Milestone 5: Polish (OPTIONAL)

**Objectives:**

- Add color-coded output (green for success, red for errors, yellow for warnings)
- Improve error messages with troubleshooting hints
- Add verbose mode for debugging
- Better dry-run preview

**What We'll Learn:**

- ANSI color codes in bash
- Functions in bash
- More advanced conditional logic

---

## 🚫 Features Deferred (Not Implementing Yet)

These exist in the PowerShell version but are NOT part of the core functionality:

- Interactive sync notes
- Conventional commit prompts
- Git auto-commit and push
- Sync history logging

We can add these later once comfortable with bash basics.

---

## Progress Tracker

- ✅ Milestone 1: Basic Script Structure
- 🔲 Milestone 2: Dependency Checking
- 🔲 Milestone 3: Path Validation
- 🔲 Milestone 4: Execute rclone bisync
- 🔲 Milestone 5: Polish

**Current Status:** Taking a break after Milestone 1. Will resume with Milestone 2.
