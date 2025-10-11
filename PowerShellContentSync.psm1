# =============================================================================
# Asset Sync Script
# =============================================================================
# Bidirectional asset synchronization using Google Drive and rclone bisync.
# See docs/ folder for detailed documentation.
# =============================================================================

param(
    [switch]$Resync,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$HistoryFile = Join-Path $PSScriptRoot "sync-history.log"

function Write-SyncHistory {
    param([string]$Message)
    
    if ([string]::IsNullOrWhiteSpace($Message)) { return }
    
    try {
        $Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        $LogLine = "$Timestamp $Message"
        Add-Content -Path $HistoryFile -Value $LogLine -Encoding UTF8
        Write-Host "Sync note recorded in history log." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to write to sync history log: $_"
    }
}

function Get-ConventionalCommit {
    param([string]$Description)
    
    Write-Host "`n--- Conventional Commit Information ---" -ForegroundColor Cyan
    Write-Host "This helps create a standardized changelog for your team." -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Select commit type:" -ForegroundColor Yellow
    Write-Host "  1. feat     - A new feature"
    Write-Host "  2. fix      - A bug fix"
    Write-Host "  3. docs     - Documentation changes"
    Write-Host "  4. style    - Code style/formatting (no logic change)"
    Write-Host "  5. refactor - Code refactoring (no feature/fix)"
    Write-Host "  6. perf     - Performance improvements"
    Write-Host "  7. test     - Adding or updating tests"
    Write-Host "  8. chore    - Maintenance tasks"
    Write-Host ""
    
    $typeChoice = Read-Host "Enter number (1-8)"
    
    $types = @{
        "1" = "feat"
        "2" = "fix"
        "3" = "docs"
        "4" = "style"
        "5" = "refactor"
        "6" = "perf"
        "7" = "test"
        "8" = "chore"
    }
    
    $commitType = $types[$typeChoice]
    if (-not $commitType) {
        Write-Host "Invalid choice, defaulting to 'chore'" -ForegroundColor Yellow
        $commitType = "chore"
    }
    
    $scope = Read-Host "Enter scope (optional, e.g., 'weapons', 'textures', or press Enter to skip)"
    $breaking = Read-Host "Is this a breaking change? (y/n)"
    $isBreaking = $breaking -eq "y" -or $breaking -eq "Y"
    
    if ($isBreaking) {
        $commitMsg = [string]::IsNullOrWhiteSpace($scope) ? 
            "${commitType}!: $Description" : "${commitType}($scope)!: $Description"
    } else {
        $commitMsg = [string]::IsNullOrWhiteSpace($scope) ? 
            "${commitType}: $Description" : "${commitType}($scope): $Description"
    }
    
    return $commitMsg
}

function Invoke-GitCommitAndPush {
    param([string]$CommitMessage)
    
    try {
        Write-Host "`n--- Git Auto-Commit ---" -ForegroundColor Cyan
        
        $gitRoot = git -C $PSScriptRoot rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitRoot)) {
            Write-Warning "No git repository found. Skipping git commit."
            return
        }
        
        $gitRoot = $gitRoot -replace '/', '\'
        $relativePath = $HistoryFile.Replace($gitRoot, "").TrimStart('\')
        
        Write-Host "Git repository: $gitRoot" -ForegroundColor Gray
        Write-Host "Committing: $relativePath" -ForegroundColor Gray
        
        git -C $gitRoot add $relativePath 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to stage sync-history.log"
            return
        }
        
        git -C $gitRoot commit -m $CommitMessage 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to commit (possibly no changes to commit)"
            return
        }
        
        Write-Host "Committed successfully!" -ForegroundColor Green
        
        $currentBranch = git -C $gitRoot rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not determine current branch"
            return
        }
        
        Write-Host "Pushing to origin/$currentBranch..." -ForegroundColor Gray
        git -C $gitRoot push origin $currentBranch 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pushed successfully!" -ForegroundColor Green
        } else {
            Write-Warning "Failed to push. You may need to push manually later."
        }
    }
    catch {
        Write-Warning "Git operation failed: $_"
        Write-Host "You can manually commit the sync-history.log file later." -ForegroundColor Yellow
    }
}

$EnvFile = "$PSScriptRoot\.env"

if (-not (Test-Path $EnvFile)) {
    Write-Host "Error: .env file not found at $EnvFile" -ForegroundColor Red
    Write-Host "Please create a .env file with your project configuration." -ForegroundColor Yellow
    exit 1
}

Get-Content $EnvFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
    $key, $value = $_ -split '=', 2
    $key = $key.Trim()
    $value = $value.Trim()
    Set-Variable -Name $key -Value $value -Scope Script
}

$AssetSource = "${REMOTE_NAME}:${REMOTE_FOLDER}"
$AssetDestination = Join-Path $PSScriptRoot $ASSET_DESTINATION

Write-Host "=== Asset Sync (Bidirectional) ===" -ForegroundColor Cyan

$RclonePath = (Get-Command rclone -ErrorAction SilentlyContinue).Source

if (-not $RclonePath) {
    $WinGetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\rclone.exe"
    if (Test-Path $WinGetPath) {
        $RclonePath = $WinGetPath
    }
}

if (-not $RclonePath) {
    Write-Host "rclone not found. Installing via winget..." -ForegroundColor Yellow
    
    try {
        winget install Rclone.Rclone --silent --accept-source-agreements
        Write-Host "rclone installed! Please close and reopen PowerShell, then run this script again." -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Host "Failed to install rclone. Please install manually from https://rclone.org/downloads/" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Using rclone at: $RclonePath" -ForegroundColor Gray

$RcloneConfigPath = Join-Path $PSScriptRoot $RCLONE_CONFIG_PATH

if (-not (Test-Path $RcloneConfigPath)) {
    Write-Host "Error: rclone config not found at $RcloneConfigPath" -ForegroundColor Red
    Write-Host "You need to configure rclone first. See docs/rclone-setup.md" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $AssetDestination)) {
    New-Item -ItemType Directory -Path $AssetDestination -Force | Out-Null
    Write-Host "Created asset destination folder: $AssetDestination" -ForegroundColor Green
}

Write-Host "`nSyncing assets bidirectionally..." -ForegroundColor Cyan
Write-Host "Google Drive: $AssetSource" -ForegroundColor Gray
Write-Host "Local: $AssetDestination" -ForegroundColor Gray
Write-Host ""

$bisyncArgs = @(
    "bisync",
    $AssetSource,
    $AssetDestination,
    "--config=$RcloneConfigPath",
    "--create-empty-src-dirs",
    "--conflict-resolve", $CONFLICT_RESOLVE,
    "--conflict-loser", $CONFLICT_LOSER,
    "--resilient",
    "--recover",
    "--max-lock", $MAX_LOCK,
    "--check-access",
    "--check-filename", $CHECK_FILENAME,
    "--compare", $COMPARE,
    "-v",
    "--progress"
)

if ($Resync) {
    $bisyncArgs += "--resync"
    Write-Host "RESYNC MODE: This will sync everything from scratch" -ForegroundColor Yellow
    Write-Host ""
}

if ($DryRun) {
    $bisyncArgs += "--dry-run"
    Write-Host "DRY RUN: No actual changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

try {
    & $RclonePath $bisyncArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=== Sync completed successfully! ===" -ForegroundColor Green
        
        Write-Host ""
        $SyncNote = Read-Host "Enter sync note (press Enter to skip)"
        
        if (-not [string]::IsNullOrWhiteSpace($SyncNote)) {
            Write-SyncHistory -Message $SyncNote
            $commitMessage = Get-ConventionalCommit -Description $SyncNote
            Invoke-GitCommitAndPush -CommitMessage $commitMessage
        }
    }
    elseif ($LASTEXITCODE -eq 2) {
        Write-Host "`n=== Sync completed with warnings ===" -ForegroundColor Yellow
        Write-Host "Check the output above for details." -ForegroundColor Yellow
        
        Write-Host ""
        $SyncNote = Read-Host "Enter sync note (press Enter to skip)"
        
        if (-not [string]::IsNullOrWhiteSpace($SyncNote)) {
            Write-SyncHistory -Message $SyncNote
            $commitMessage = Get-ConventionalCommit -Description $SyncNote
            Invoke-GitCommitAndPush -CommitMessage $commitMessage
        }
    }
    else {
        Write-Host "`n=== Sync failed ===" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
catch {
    Write-Host "`nError during sync: $_" -ForegroundColor Red
    
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "- If this is the first run, try: .\sync-assets.ps1 -Resync" -ForegroundColor Yellow
    Write-Host "- Ensure RCLONE_TEST file exists in both locations" -ForegroundColor Yellow
    Write-Host "- Check that the Google Drive folder name is correct" -ForegroundColor Yellow
    Write-Host "- Verify you have access to the shared Google Drive folder" -ForegroundColor Yellow
    
    exit 1
}

Write-Host "`nAssets are ready!" -ForegroundColor Cyan
