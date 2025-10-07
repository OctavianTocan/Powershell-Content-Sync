#!/usr/bin/env bash
# =============================================================================
# Asset Sync Script (Bash Version)
# =============================================================================
# Bidirectional asset synchronization using Google Drive and rclone bisync.
# =============================================================================

# Exit immediately if a command fails (like PowerShell's $ErrorActionPreference = "Stop")
set -e

# Get the directory where this script lives (equivalent to $PSScriptRoot)
# Breakdown: dirname gets the directory path, cd moves there, pwd prints absolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command-line arguments
RESYNC=false
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        --resync)
            RESYNC=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--resync] [--dry-run]"
            exit 1
            ;;
    esac
done

# Load .env file
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "Please create a .env file with your project configuration."
    exit 1
fi

# Parse the .env file and set variables
while IFS= read -r line; do
    # Skip comments (lines starting with #) and empty lines
    if [[ $line =~ ^[[:space:]]*# ]] || [[ -z $line ]]; then
        continue
    fi
    
    # Process lines with = sign
    if [[ $line == *"="* ]]; then
        key="${line%%=*}"              # Everything before first =
        value="${line#*=}"             # Everything after first =
        key=$(echo "$key" | xargs)     # Trim whitespace from key
        value=$(echo "$value" | xargs) # Trim whitespace from value
        declare "$key=$value"          # Create the variable dynamically
    fi
done < "$ENV_FILE"


echo "Script initialized successfully!"
echo "RESYNC mode: $RESYNC"
echo "DRY_RUN mode: $DRY_RUN"