<#
.SYNOPSIS
  Migrates selected documentation folders from this repository into another repository (e.g. sumofme-insiders).

.DESCRIPTION
  Copies (optionally removes) the specified source folders (default: docs/family-tech, docs/leadership-personal)
  into a target repository working copy, commits, and optionally pushes both source and target changes.

  This is a content migration (file copy) – it does NOT preserve individual file git history. If you require
  full history extraction, use git filter-repo separately.

.PARAMETER SourceRepoPath
  Path to the current (source) repository root. Defaults to script parent parent if omitted.

.PARAMETER TargetRepoUrl
  Clone URL (HTTPS or SSH) for the target repository.

.PARAMETER TargetLocalPath
  Local path where the target repository should exist / be cloned.

.PARAMETER FoldersToMove
  Relative folder paths (from source root) to migrate.

.PARAMETER KeepOriginal
  If set, the folders are copied but NOT removed from the source repo.

.PARAMETER Push
  If set, pushes commits to both origin remotes (source if removal happened, target always if changes exist).

.PARAMETER CommitMessageSuffix
  Optional suffix appended to the auto-generated commit messages.

.EXAMPLE
  .\Migrate-PersonalContent.ps1 -TargetRepoUrl https://github.com/mp2301/sumofme-insiders.git -TargetLocalPath ..\sumofme-insiders -Push

.EXAMPLE (Keep originals)
  .\Migrate-PersonalContent.ps1 -TargetRepoUrl git@github.com:mp2301/sumofme-insiders.git -TargetLocalPath C:\Repos\sumofme-insiders -KeepOriginal -Push

#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [string]$SourceRepoPath = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [Parameter(Mandatory=$true)][string]$TargetRepoUrl,
    [Parameter(Mandatory=$true)][string]$TargetLocalPath,
    [string[]]$FoldersToMove = @('docs/family-tech','docs/leadership-personal'),
    [switch]$KeepOriginal,
    [switch]$Push,
    [string]$CommitMessageSuffix
)

function Write-Info { param($m) Write-Host "[INFO ] $m" -ForegroundColor Cyan }
function Write-Warn { param($m) Write-Host "[WARN ] $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }

function Assert-Executable {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'git command not found in PATH.'
    }
}

function Test-GitClean {
    param([string]$Path)
    $status = (git -C $Path status --porcelain)
    return [string]::IsNullOrWhiteSpace($status)
}

try {
    Assert-Executable
    $SourceRepoPath = (Resolve-Path $SourceRepoPath).Path
    if (-not (Test-Path (Join-Path $SourceRepoPath '.git'))) { throw "SourceRepoPath '$SourceRepoPath' is not a git repo" }

    if (-not (Test-Path $TargetLocalPath)) {
        Write-Info "Cloning target repository to $TargetLocalPath"
        git clone $TargetRepoUrl $TargetLocalPath | Out-Null
    } else {
        if (-not (Test-Path (Join-Path $TargetLocalPath '.git'))) { throw "TargetLocalPath exists but is not a git repo" }
        Write-Info "Fetching latest in target repo"
        git -C $TargetLocalPath fetch --all --prune | Out-Null
        git -C $TargetLocalPath pull --ff-only | Out-Null
    }

    if (-not (Test-GitClean -Path $SourceRepoPath)) { Write-Warn 'Source repo has uncommitted changes – they will NOT be included in migration unless committed first.' }
    if (-not (Test-GitClean -Path $TargetLocalPath)) { throw 'Target repository has uncommitted changes – please commit or stash before running.' }

    $migrated = @()
    foreach ($rel in $FoldersToMove) {
        $srcPath = Join-Path $SourceRepoPath $rel
        if (-not (Test-Path $srcPath)) { Write-Warn "Skipping missing folder: $rel"; continue }
        $destPath = Join-Path $TargetLocalPath $rel
        Write-Info "Copying $rel -> $destPath"
        New-Item -ItemType Directory -Force -Path (Split-Path $destPath) | Out-Null
        if (Test-Path $destPath) { Remove-Item $destPath -Recurse -Force }
        Copy-Item $srcPath $destPath -Recurse -Force
        $migrated += $rel
    }

    if ($migrated.Count -eq 0) { throw 'No folders migrated; aborting.' }

    git -C $TargetLocalPath add $migrated
    $targetMsg = "docs: migrate folders from sumofme -> $( ($migrated -join ',') )"
    if ($CommitMessageSuffix) { $targetMsg = "$targetMsg - $CommitMessageSuffix" }
    git -C $TargetLocalPath commit -m $targetMsg | Out-Null
    Write-Info "Committed migration in target repo."    

    if (-not $KeepOriginal) {
        foreach ($rel in $migrated) {
            $srcFull = Join-Path $SourceRepoPath $rel
            if (Test-Path $srcFull) {
                Write-Info "Removing source folder $rel"
                Remove-Item $srcFull -Recurse -Force
                git -C $SourceRepoPath rm -r $rel | Out-Null
            }
        }
        $srcMsg = "chore: remove migrated folders -> $( ($migrated -join ',') )"
        if ($CommitMessageSuffix) { $srcMsg = "$srcMsg - $CommitMessageSuffix" }
        git -C $SourceRepoPath commit -m $srcMsg | Out-Null
        Write-Info "Committed removal in source repo."
    } else {
        Write-Info 'KeepOriginal set – source folders retained.'
    }

    if ($Push) {
        Write-Info 'Pushing target repo changes'
        git -C $TargetLocalPath push
        if (-not $KeepOriginal) {
            Write-Info 'Pushing source repo changes'
            git -C $SourceRepoPath push
        }
    } else {
        Write-Warn 'Push flag not set – changes only local.'
    }

    Write-Info 'Migration complete.'
    if (-not $KeepOriginal) { Write-Info 'Validate any links pointing to migrated content.' }
}
catch {
    Write-Err $_.Exception.Message
    exit 1
}