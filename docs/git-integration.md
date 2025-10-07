# Git Integration

## Sync History Logging

After successful syncs, the script prompts for an optional sync note. This creates a human-readable audit trail in `sync-history.log`:

```
2025-01-07T12:30:00Z Added new weapon textures
2025-01-07T14:15:00Z Fixed material shader issues
```

## Conventional Commits

The script guides users through creating standardized commit messages following [Conventional Commits](https://www.conventionalcommits.org/) format.

### Commit Types

1. `feat` - A new feature
2. `fix` - A bug fix
3. `docs` - Documentation changes
4. `style` - Code style/formatting (no logic change)
5. `refactor` - Code refactoring (no feature/fix)
6. `perf` - Performance improvements
7. `test` - Adding or updating tests
8. `chore` - Maintenance tasks

### Optional Elements

- **Scope**: Area affected (e.g., `weapons`, `textures`)
- **Breaking change**: Indicates breaking changes with `!`

### Examples

```
feat: add new weapon variants
fix(weapons): resolve texture loading bug
feat!: redesign inventory system (breaking change)
```

## Auto-Commit Process

1. **Sync completion**: Script detects successful sync
2. **User prompt**: Asks for sync note (optional)
3. **Commit type selection**: Interactive menu for commit type
4. **Scope input**: Optional scope entry
5. **Breaking change check**: Yes/no prompt
6. **Git operations**:
   - Find parent repository root
   - Stage `sync-history.log`
   - Create commit with conventional message
   - Push to origin

## Functions

### Write-SyncHistory

- Appends timestamped message to `sync-history.log`
- Uses ISO 8601 format for consistency
- UTF-8 encoding for international characters
- Non-fatal: Logging failures don't stop sync

### Get-ConventionalCommit

- Interactive prompt for commit type selection
- Builds properly formatted commit message
- Handles breaking changes and scopes

### Invoke-GitCommitAndPush

- Locates parent git repository
- Calculates relative path to sync log
- Stages and commits only the log file
- Pushes to current branch
- Graceful error handling for git failures

## Benefits

- **Team visibility**: Asset changes tracked in git history
- **Standardization**: Consistent commit message format
- **Audit trail**: Timestamped log of all sync operations
- **Non-intrusive**: Only commits sync log, not user changes
