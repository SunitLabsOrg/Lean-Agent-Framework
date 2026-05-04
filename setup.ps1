# Lean Agent Framework Setup Script (Windows PowerShell)
# Configures symlinks for all AI tools to read the same AGENTS.md

param(
    [string]$tools = "all",
    [switch]$help = $false
)

$script:ProjectRoot = $null

# Colors and output helpers
function Write-Status {
    param([string]$message)
    Write-Host "[INFO] $message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$message)
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$message)
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$message)
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Show help
function Show-Help {
    @"
Lean Agent Framework Setup Script (Windows)

Usage: powershell -ExecutionPolicy Bypass -File setup.ps1 [-tools TOOLS] [-help]

Options:
  -tools TOOLS      Comma-separated list of tools to configure
                    Valid: cursor, claude, copilot, windsurf, kiro, all (default: all)
  -help            Show this help message

Prerequisites:
  On Windows, run PowerShell as Administrator or enable Developer Mode so
  symlinks can be created successfully.

Examples:
  powershell -ExecutionPolicy Bypass -File setup.ps1
  powershell -ExecutionPolicy Bypass -File setup.ps1 -tools "cursor,claude,copilot"
  powershell -ExecutionPolicy Bypass -File setup.ps1 -tools "cursor"
  powershell -ExecutionPolicy Bypass -File setup.ps1 -help

After setup:
  1. Verify AGENTS.md is in your project root
  2. Customize CONVENTIONS.md for your team's stack
  3. Commit link files to git: git add .cursorrules .claude.md .windsurfrules etc.
  4. Start using with your AI tools - they'll all read the same AGENTS.md!

All tools will read the same AGENTS.md via symlinks.
Edit AGENTS.md once, and linked configs stay in sync.
"@
}

# Check if we're in a git repository
function Check-GitRepo {
    try {
        $script:ProjectRoot = (git rev-parse --show-toplevel 2>$null).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw "Not a git repository"
        }
        Set-Location $script:ProjectRoot
    }
    catch {
        Write-Error-Custom "Not in a git repository. Please run this script from your project root."
        exit 1
    }
}

# Verify AGENTS.md exists
function Check-AgentsMd {
    if (-not (Test-Path "AGENTS.md")) {
        Write-Error-Custom "AGENTS.md not found in current directory. Please copy it first:"
        Write-Host "  cp .laf\AGENTS.md ." -ForegroundColor Gray
        exit 1
    }
}

# Verify CONVENTIONS.md exists
function Check-ConventionsMd {
    if (-not (Test-Path "CONVENTIONS.md")) {
        Write-Warning "CONVENTIONS.md not found. Creating from template..."
        if (Test-Path ".laf\CONVENTIONS.md") {
            Copy-Item ".laf\CONVENTIONS.md" "CONVENTIONS.md"
            Write-Success "CONVENTIONS.md created. Please customize it."
        }
        else {
            Write-Error-Custom "Could not find CONVENTIONS.md template."
            exit 1
        }
    }
}

# Create symlink helper
function New-SymlinkForce {
    param(
        [string]$Target,
        [string]$Link
    )
    
    # Ensure directory exists
    $dir = Split-Path -Parent $Link
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    # Remove existing link/file
    if (Test-Path $Link) {
        Remove-Item $Link -Force -ErrorAction SilentlyContinue
    }
    
    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        $errorText = @(
            $_.Exception.Message
            $_.FullyQualifiedErrorId
            $_.CategoryInfo.Reason
        ) -join " "

        if ($errorText -match 'Administrator privilege|elevation|privilege|ElevationRequired|UnauthorizedAccess') {
            throw "Symlink creation requires Administrator privileges or Windows Developer Mode. Re-run PowerShell as Administrator, or enable Developer Mode, then try again."
        }

        throw "Could not create symlink: $Link -> $Target. $($_.Exception.Message)"
    }
}

# Resolve paths relative to the detected project root.
function Get-ProjectPath {
    param([string]$RelativePath)

    if (-not $script:ProjectRoot) {
        $script:ProjectRoot = (Get-Location).Path
    }

    return (Join-Path $script:ProjectRoot $RelativePath)
}

# Setup all tools
function Setup-AllTools {
    Write-Status "Setting up AI tool configurations symlinked to AGENTS.md..."

    # Cursor
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".cursor/rules.md" | Out-Null
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".cursorrules" | Out-Null
    Write-Success "[OK] Cursor configured"

    # GitHub Copilot
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".github/copilot-instructions.md" | Out-Null
    Write-Success "[OK] GitHub Copilot configured"

    # Windsurf
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".windsurfrules" | Out-Null
    Write-Success "[OK] Windsurf configured"

    # Claude Code
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".claude.md" | Out-Null
    Write-Success "[OK] Claude Code configured"

    # Kiro
    New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".kiro/steering/agents.md" | Out-Null
    Write-Success "[OK] Kiro configured"

    Write-Success "All AI tools configured!"
}

# Setup specific tool
function Setup-Tool {
    param([string]$tool)
    
    $tool = $tool.Trim().ToLower()
    
    switch ($tool) {
        "cursor" {
            Write-Status "Setting up Cursor..."
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".cursor/rules.md" | Out-Null
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".cursorrules" | Out-Null
            Write-Success "[OK] Cursor configured"
        }
        "claude" {
            Write-Status "Setting up Claude Code..."
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".claude.md" | Out-Null
            Write-Success "[OK] Claude Code configured"
        }
        "copilot" {
            Write-Status "Setting up GitHub Copilot..."
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".github/copilot-instructions.md" | Out-Null
            Write-Success "[OK] GitHub Copilot configured"
        }
        "windsurf" {
            Write-Status "Setting up Windsurf..."
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".windsurfrules" | Out-Null
            Write-Success "[OK] Windsurf configured"
        }
        "kiro" {
            Write-Status "Setting up Kiro..."
            New-SymlinkForce -Target (Get-ProjectPath "AGENTS.md") -Link ".kiro/steering/agents.md" | Out-Null
            Write-Success "[OK] Kiro configured"
        }
        default {
            Write-Warning "Unknown tool: $tool (skipping)"
        }
    }
}

# Main
function Main {
    Write-Host ""
    Write-Host "Lean Agent Framework Setup" -ForegroundColor Magenta
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host ""

    if ($help) {
        Show-Help
        exit 0
    }

    # Verify prerequisites
    Check-GitRepo
    Check-AgentsMd
    Check-ConventionsMd

    try {
        # Setup based on tools argument
        if ($tools -eq "all") {
            Setup-AllTools
        }
        else {
            $toolArray = $tools -split "," | ForEach-Object { $_.Trim() }
            foreach ($tool in $toolArray) {
                Setup-Tool -tool $tool
            }
        }
    }
    catch {
        Write-Error-Custom $_.Exception.Message
        exit 1
    }

    Write-Host ""
    Write-Success "Setup complete!"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. [OK] All AI tools now read from AGENTS.md"
    Write-Host "2. [INFO] Customize CONVENTIONS.md for your team's stack"
    Write-Host "3. Commit symlink files to git:"
    Write-Host "     git add .cursorrules .claude.md .windsurfrules .github/ .cursor/ .kiro/" -ForegroundColor Gray
    Write-Host "     git commit -m 'chore: Configure AI tools to read shared AGENTS.md'" -ForegroundColor Gray
    Write-Host "4. Start using! All tools see the same rules."
    Write-Host ""
    Write-Host "Pro tip: Edit AGENTS.md once, all tools read the update instantly!" -ForegroundColor Yellow
    Write-Host ""
}

# Run main
Main
