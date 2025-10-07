# Asset Sync - AI Coding Assistant Guidelines

## Architecture Overview

This is a PowerShell-based bidirectional asset synchronization system using Google Drive and rclone's bisync feature. Key components:

- `sync-assets.ps1`: Main bisync script with extensive error handling
- `.env`: Configuration-driven settings (committed to git)
- `.rclone/rclone.conf`: Shared rclone config (committed)
- `.rclone/service-account.json`: Manually placed credentials (gitignored)

## Critical Developer Workflows

**Initial Setup:**

```powershell
# 1. Place service-account.json in .rclone/ (see .rclone/README.md)
# 2. Run first sync
.\sync-assets.ps1 -Resync   # First full sync
```

**Daily Usage:**

```powershell
.\sync-assets.ps1  # Before/after work sessions
```

**Troubleshooting:**

```powershell
.\sync-assets.ps1 -DryRun   # Preview changes
New-Item -Path "..\Content\RCLONE_TEST" -ItemType File -Force  # Create safety file
```

## Project-Specific Patterns

### Configuration Loading

Always load settings from `.env` file using this pattern:

```powershell
Get-Content $EnvFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
    $key, $value = $_ -split '=', 2
    Set-Variable -Name $key.Trim() -Value $value.Trim() -Scope Script
}
```

### Path Resolution

Use `$PSScriptRoot` for relative paths and `Join-Path` for construction:

```powershell
$AssetDestination = Join-Path $PSScriptRoot $ASSET_DESTINATION
```

### Error Handling

Use try/catch with helpful user messages and exit codes:

```powershell
try {
    # operation
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
```

### rclone Integration

- Service account authentication via `service_account_file` in rclone.conf
- Bisync with `--check-access` using RCLONE_TEST files for safety
- Conflict resolution configured via .env variables

### Security Model

- Service account credentials placed manually in .rclone/service-account.json
- .rclone/ folder shared but service-account.json gitignored
- No personal OAuth tokens - all users share same service account

## Key Files to Reference

- `sync-assets.ps1`: Main sync logic and rclone command construction
- `.rclone/service-account.json.example`: Example credential file
- `.env`: Configuration structure and available variables
- `.gitignore`: Security boundaries (what's ignored vs committed)

## Common Patterns

- Extensive inline documentation with source links
- WinGet auto-installation for dependencies
- Color-coded console output for user feedback
- Configuration validation before operations
- Safety checks prevent accidental wrong-path syncs
