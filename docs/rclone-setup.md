# rclone Setup Guide

## Installation

The script automatically installs rclone via WinGet if not found. Manual installation available from [rclone.org/downloads](https://rclone.org/downloads/).

### Automatic Installation

```powershell
winget install Rclone.Rclone --silent --accept-source-agreements
```

### Location Detection

The script searches for rclone in:

1. Windows PATH
2. WinGet installation directory: `%LOCALAPPDATA%\Microsoft\WinGet\Links\`

## Configuration

### Service Account Authentication

1. **Create Service Account**:

   - Google Cloud Console → IAM & Admin → Service Accounts
   - Create account with "Editor" role
   - Generate JSON key

2. **Place Credentials**:

   - Save JSON as `.rclone/service-account.json`
   - Never commit this file (gitignored)

3. **Configure rclone.conf**:
   ```ini
   [gdrive]
   type = drive
   scope = drive
   service_account_file = .rclone/service-account.json
   ```

### Why Service Accounts?

- **Server-to-server auth**: No interactive login required
- **Shared credentials**: All team members use same account
- **CI/CD friendly**: Perfect for automated environments
- **Scoped access**: Only accesses configured Drive folder

## Security Considerations

- Service account JSON contains private keys
- Store securely, limit access to authorized personnel
- Use Google Cloud IAM for permission control
- Never share config files containing OAuth tokens

## Verification

The script verifies:

- rclone executable exists
- Config file is present
- Service account file accessible
- Paths are valid

## Troubleshooting

### "rclone not found"

- Restart PowerShell after WinGet installation
- Add rclone to PATH manually
- Check WinGet installation location

### "Config not found"

- Ensure `.rclone/rclone.conf` exists
- Verify file path in `.env`

### Authentication errors

- Check service account JSON validity
- Verify Google Drive sharing permissions
- Confirm service account has Editor access

## References

- [rclone documentation](https://rclone.org/docs/)
- [Service account overview](https://cloud.google.com/iam/docs/service-account-overview)
- [Google Drive API auth](https://developers.google.com/workspace/drive/api/guides/api-specific-auth)
