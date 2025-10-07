# Asset Sync Architecture

## Overview

This PowerShell script provides bidirectional asset synchronization between Google Drive and local machine using rclone's bisync feature. It's designed for team collaboration with shared service account authentication.

## Why This Exists

- **GitHub LFS Cost**: Too expensive for large projects (1GB free storage)
- **Bidirectional Sync**: One-way sync doesn't work when multiple people make changes
- **Conflict Resolution**: Bisync handles changes from both sides intelligently

## Security Model

- Each user authenticates with their own Google account
- Drive folder is shared via Google Drive's sharing feature
- Never share your rclone.conf file with others
- Service account credentials are placed manually in `.rclone/service-account.json`

## Key Components

- `sync-assets.ps1`: Main sync script
- `.env`: Project-specific configuration
- `.rclone/rclone.conf`: Shared rclone configuration
- `.rclone/service-account.json`: Service account credentials (gitignored)

## References

- [rclone bisync documentation](https://rclone.org/bisync/)
- [Google Drive API scopes](https://developers.google.com/workspace/drive/api/guides/api-specific-auth)
- [Conflict resolution](https://github.com/rclone/rclone/issues/7471)
- [OAuth security](https://forum.rclone.org/t/how-share-rclone-conf-to-someone-but-with-their-account-credentials/29644)
