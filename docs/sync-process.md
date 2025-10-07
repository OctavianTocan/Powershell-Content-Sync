# Sync Process Details

## rclone bisync Command

The script constructs and executes an rclone bisync command with the following arguments:

### Core Arguments

- `bisync`: Bidirectional sync command
- `$AssetSource`: Google Drive path (`remotename:path/to/folder`)
- `$AssetDestination`: Local path
- `--config=$RcloneConfigPath`: Custom config file location

### Directory Handling

- `--create-empty-src-dirs`: Creates empty folders to preserve project structure

### Conflict Resolution

- `--conflict-resolve $CONFLICT_RESOLVE`: Strategy when both sides modified same file
  - `newer`: Keep newer file (default)
  - `older`: Keep older file
  - `larger`: Keep larger file
  - `smaller`: Keep smaller file
  - `path1`: Keep path1 version
  - `path2`: Keep path2 version
- `--conflict-loser $CONFLICT_LOSER`: What to do with losing version
  - `num`: Rename with `.conflict1`, `.conflict2` (default)
  - `delete`: Remove losing version
  - `pathname`: Rename with path info

### Reliability

- `--resilient`: Continue on errors instead of stopping
- `--recover`: Auto-recover from interrupted syncs
- `--max-lock $MAX_LOCK`: Maximum time to hold lock file

### Safety

- `--check-access`: Verify both paths accessible via safety file
- `--check-filename $CHECK_FILENAME`: Name of safety check file (default: `RCLONE_TEST`)

### Performance

- `--compare $COMPARE`: File comparison method
  - `size,modtime`: Fast, compares size and modification time
  - `checksum`: Accurate but slower, uses cryptographic hashes

### Output

- `-v`: Verbose output showing transferred files
- `--progress`: Show transfer progress with percentage and speed

## Command Line Parameters

### -Resync

Forces complete resynchronization from scratch. Use when:

- First time setup
- After interruptions
- Database corruption detected

### -DryRun

Shows what would happen without making changes. Use for:

- Testing changes
- Before first real sync
- Verifying behavior

## Exit Codes

- `0`: Success
- `1`: Error (script exits)
- `2`: Warnings but operation completed

## Error Handling

The script uses PowerShell's `$ErrorActionPreference = "Stop"` to fail fast on errors. Try/catch blocks handle:

- rclone execution errors
- File system permission issues
- Network connectivity problems

## Troubleshooting

Common issues and solutions:

- **RCLONE_TEST missing**: Create empty file in both locations
- **Permission denied**: Check Google Drive sharing settings
- **Config not found**: Ensure `.rclone/rclone.conf` exists
- **Service account issues**: Verify JSON file and Drive access
- **Lock file stuck**: Wait for lock timeout or manual cleanup
