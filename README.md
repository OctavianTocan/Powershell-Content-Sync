# Asset Sync

Bidirectional asset synchronization using Google Drive and rclone. Designed for team collaboration with shared service account authentication.

## What's Inside

- `sync-assets.ps1` - The main sync script
- [Wiki](https://github.com/OctavianTocan/Powershell-Content-Sync/wiki) - Detailed documentation and guides
- `.env` - Project-specific configuration
- `.rclone/rclone.conf` - Shared rclone configuration (committed to Git)
- `.rclone/service-account.json` - Service account credentials (gitignored, not shared)
- `.rclone/service-account.json.example` - Example service account JSON with fake data
- `RCLONE_TEST` - Safety check file that must exist in both locations
- `sync-history.log` - Chronological log of sync operations with user notes

**Security Note**: The `.rclone/` folder is shared and committed to Git, but the `service-account.json` file within it is gitignored. Each team member must obtain their own copy of the service account JSON and place it at `.rclone/service-account.json`.

## Quick Start

1. Obtain your Google Service Account JSON credentials and place them at `.rclone/service-account.json`. See `.rclone/README.md` for details.

2. Run the initial sync:

```powershell
.\sync-assets.ps1 -Resync
```

**If it fails** and mentions the `RCLONE_TEST` file is missing, create it:

```powershell
New-Item -Path "..\Content\RCLONE_TEST" -ItemType File -Force
```

Then run the sync again.

**Note**: After successful sync, you'll be prompted to enter an optional note about what changed. This helps track the history of modifications.

## Day-to-Day Usage

**Before starting work:**

```powershell
.\sync-assets.ps1
```

**After making changes:**

```powershell
.\sync-assets.ps1
```

**Before ending your session:**

```powershell
.\sync-assets.ps1
```

The script handles bidirectional sync automatically - uploads and downloads happen in the same operation.

### Sync History & Changelog

After each successful sync, you'll be prompted to enter an optional note describing what changed. The script then guides you through creating a **Conventional Commit** message that gets automatically committed and pushed to the repository.

**How it works:**

1. **Enter sync note**: Describe what you changed (e.g., "Added new M4A1 texture variants")
2. **Select commit type**: Choose from a numbered menu:
   - `feat` - A new feature
   - `fix` - A bug fix
   - `docs` - Documentation changes
   - `style` - Code style/formatting (no logic change)
   - `refactor` - Code refactoring (no feature/fix)
   - `perf` - Performance improvements
   - `test` - Adding or updating tests
   - `chore` - Maintenance tasks
3. **Enter scope** (optional): What area? (e.g., "weapons", "textures")
4. **Breaking change?**: Yes or no
5. The script automatically commits and pushes `sync-history.log` to the repository

**Benefits:**

- Customers can see asset changes via `git log` or by viewing `sync-history.log`
- Standardized changelog format across the team
- No need to memorize Conventional Commits syntax
- Only `sync-history.log` is committed (your other work remains untouched)

**Example log entries:**

```
2025-01-07T09:30:00Z Added new M4A1 texture variants
2025-01-07T14:15:00Z Fixed UV mapping on AK-47 model
2025-01-08T10:00:00Z Updated weapon materials for better reflections
```

**To skip:** Press Enter without typing anything when prompted for a sync note. This skips the entire commit process.

## Configuration (`.env` File)

The `.env` file contains all project-specific settings and is included in the repository.

| Variable             | Description                    | Example                               |
| -------------------- | ------------------------------ | ------------------------------------- |
| `REMOTE_NAME`        | Name of your rclone remote     | `gdrive`                              |
| `REMOTE_FOLDER`      | Path in Google Drive           | `MyProject/Content`                   |
| `ASSET_DESTINATION`  | Local destination path         | `..\Content`                          |
| `RCLONE_CONFIG_PATH` | Path to rclone config          | `.rclone\rclone.conf`                 |
| `CHECK_FILENAME`     | Safety check file name         | `RCLONE_TEST`                         |
| `CONFLICT_RESOLVE`   | Conflict resolution strategy   | `newer`, `older`, `larger`, `smaller` |
| `CONFLICT_LOSER`     | What to do with losing version | `num`, `delete`, `pathname`           |
| `MAX_LOCK`           | Max lock duration              | `15m`, `30m`, `1h`                    |
| `COMPARE`            | File comparison method         | `size,modtime`, `checksum`            |

Edit `.env` in a text editor to change any settings.

## Why This Is Safe

- **Shared service account**: All team members use the same Google Service Account credentials for consistent access
- **Isolated credentials**: Only the `service-account.json` file is gitignored - the `.rclone/` folder structure is shared
- **Scoped access**: rclone only accesses the specific Google Drive folder you configured
- **Local config**: Configuration stays in your repository's `.rclone/` folder, not global `%APPDATA%`
- **Conflict preservation**: Bisync renames conflicting files (e.g., `file.conflict1`) instead of deleting them
- **Safety checks**: The `RCLONE_TEST` file prevents syncing to wrong folders

## Common Questions

### Script Execution Blocked

**Problem**: PowerShell execution policy prevents running the script

**Solution**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### RCLONE_TEST Missing

**Problem**: `rclone says RCLONE_TEST is missing`

**Solution**: Recreate the file:

```powershell
New-Item -Path "..\Content\RCLONE_TEST" -ItemType File -Force
```

Then rerun with `-Resync`.

### Sync Failed Mid-Operation

**Problem**: Sync was interrupted or failed

**Solution**: Re-run with `-Resync`:

```powershell
.\sync-assets.ps1 -Resync
```

### Change Configuration

**Problem**: Need to change remote name, folder path, or other settings

**Solution**: Edit `.env` manually with a text editor.

### Conflict Files Appearing

**Problem**: Files ending in `.conflict1`, `.conflict2` are appearing

**Explanation**: This happens when both you and a teammate modified the same file between syncs. The newer version wins (by default), and the older version is renamed.

**Prevention**:

- Sync frequently (multiple times per day)
- Communicate with team about who's working on what
- Work on different assets when possible

### Performance Issues

**Problem**: Syncing is slow

**Solutions**:

- Use `size,modtime` comparison instead of `checksum` in `.env`
- Ensure good internet connection
- Consider adding performance flags (see advanced configuration in the script)
