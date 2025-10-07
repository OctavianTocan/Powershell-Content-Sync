# Configuration Guide

## .env File Configuration

The script loads settings from a `.env` file in the same directory. Copy `.env.example` to `.env` and modify as needed.

### Required Variables

| Variable             | Description                | Example               |
| -------------------- | -------------------------- | --------------------- |
| `REMOTE_NAME`        | Name of your rclone remote | `gdrive`              |
| `REMOTE_FOLDER`      | Path in Google Drive       | `MyProject/Content`   |
| `ASSET_DESTINATION`  | Local destination path     | `..\Content`          |
| `RCLONE_CONFIG_PATH` | Path to rclone config      | `.rclone\rclone.conf` |
| `CHECK_FILENAME`     | Safety check file name     | `RCLONE_TEST`         |

### Optional Variables

| Variable           | Description                    | Default        | Options                                                 |
| ------------------ | ------------------------------ | -------------- | ------------------------------------------------------- |
| `CONFLICT_RESOLVE` | Conflict resolution strategy   | `newer`        | `newer`, `older`, `larger`, `smaller`, `path1`, `path2` |
| `CONFLICT_LOSER`   | What to do with losing version | `num`          | `num`, `delete`, `pathname`                             |
| `MAX_LOCK`         | Max lock duration              | `15m`          | Time with unit (e.g., `15m`, `1h`, `30s`)               |
| `COMPARE`          | File comparison method         | `size,modtime` | `size,modtime`, `checksum`                              |

## rclone Configuration

### Service Account Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable the Google Drive API
4. Create a Service Account with Editor role
5. Download the JSON key and place it at `.rclone/service-account.json`

### rclone.conf Setup

The `.rclone/rclone.conf` file should contain:

```ini
[gdrive]
type = drive
scope = drive
service_account_file = .rclone/service-account.json
```

## Safety Features

- **RCLONE_TEST file**: Must exist in both source and destination
- **Check access**: Verifies paths are accessible before sync
- **Conflict resolution**: Handles simultaneous changes gracefully
- **Lock files**: Prevents concurrent sync operations

## Path Resolution

- `$PSScriptRoot`: Directory containing the script
- `$AssetSource`: `"${REMOTE_NAME}:${REMOTE_FOLDER}"`
- `$AssetDestination`: `Join-Path $PSScriptRoot $ASSET_DESTINATION`
