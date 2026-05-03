#!/bin/bash

# Lean Agent Framework Setup Script
# Configures symlinks for all AI tools to read the same AGENTS.md

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
check_git_repo() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from your project root."
    exit 1
  fi
}

# Verify AGENTS.md exists
check_agents_md() {
  if [ ! -f "AGENTS.md" ]; then
    print_error "AGENTS.md not found in current directory. Please copy it first:"
    echo "  cp .laf/AGENTS.md ."
    exit 1
  fi
}

# Verify CONVENTIONS.md exists
check_conventions_md() {
  if [ ! -f "CONVENTIONS.md" ]; then
    print_warning "CONVENTIONS.md not found. Creating from template..."
    if [ -f ".laf/CONVENTIONS.md" ]; then
      cp ".laf/CONVENTIONS.md" "CONVENTIONS.md"
      print_success "CONVENTIONS.md created. Please customize it."
    else
      print_error "Could not find CONVENTIONS.md template."
      exit 1
    fi
  fi
}

# Create symlinks for all tools
setup_all_tools() {
  print_status "Setting up AI tool configurations (symlinked to AGENTS.md)..."

  # Cursor
  mkdir -p .cursor
  ln -sf ../AGENTS.md .cursor/rules.md 2>/dev/null || true
  ln -sf AGENTS.md .cursorrules 2>/dev/null || true
  print_success "✓ Cursor configured"

  # GitHub Copilot
  mkdir -p .github
  ln -sf ../AGENTS.md .github/copilot-instructions.md 2>/dev/null || true
  print_success "✓ GitHub Copilot configured"

  # Windsurf
  ln -sf AGENTS.md .windsurfrules 2>/dev/null || true
  print_success "✓ Windsurf configured"

  # Claude Code
  ln -sf AGENTS.md .claude.md 2>/dev/null || true
  print_success "✓ Claude Code configured"

  # Gemini (fallback, may not be used)
  ln -sf AGENTS.md gemini-rules.md 2>/dev/null || true

  # Kiro
  mkdir -p .kiro/steering
  ln -sf ../../AGENTS.md .kiro/steering/agents.md 2>/dev/null || true
  print_success "✓ Kiro configured"

  print_success "All AI tools configured!"
}

# Setup only cursor
setup_cursor() {
  print_status "Setting up Cursor..."
  mkdir -p .cursor
  ln -sf ../AGENTS.md .cursor/rules.md 2>/dev/null || true
  ln -sf AGENTS.md .cursorrules 2>/dev/null || true
  print_success "✓ Cursor configured"
}

# Setup only claude
setup_claude() {
  print_status "Setting up Claude Code..."
  ln -sf AGENTS.md .claude.md 2>/dev/null || true
  print_success "✓ Claude Code configured"
}

# Setup only copilot
setup_copilot() {
  print_status "Setting up GitHub Copilot..."
  mkdir -p .github
  ln -sf ../AGENTS.md .github/copilot-instructions.md 2>/dev/null || true
  print_success "✓ GitHub Copilot configured"
}

# Setup only windsurf
setup_windsurf() {
  print_status "Setting up Windsurf..."
  ln -sf AGENTS.md .windsurfrules 2>/dev/null || true
  print_success "✓ Windsurf configured"
}

# Setup only kiro
setup_kiro() {
  print_status "Setting up Kiro..."
  mkdir -p .kiro/steering
  ln -sf ../../AGENTS.md .kiro/steering/agents.md 2>/dev/null || true
  print_success "✓ Kiro configured"
}

# Show help
show_help() {
  cat <<EOF
Lean Agent Framework Setup Script

Usage: bash setup.sh [OPTIONS]

Options:
  --tools TOOLS      Comma-separated list of tools to configure
                     Valid: cursor, claude, copilot, windsurf, kiro, all (default: all)
  --help            Show this help message

Examples:
  bash setup.sh                                      # Setup all tools
  bash setup.sh --tools cursor,claude,copilot       # Setup specific tools
  bash setup.sh --tools cursor                       # Setup just Cursor
  bash setup.sh --help                               # Show this help

After setup:
  1. Verify AGENTS.md is in your project root
  2. Customize CONVENTIONS.md for your team's stack
  3. Commit symlinks to git: git add .cursorrules .claude.md .windsurfrules etc.
  4. Start using with your AI tools - they'll all read the same AGENTS.md!

All tools will read the same AGENTS.md via symlinks.
Edit AGENTS.md once, all tools see the update.

EOF
}

# Main
main() {
  echo "🤖 Lean Agent Framework Setup"
  echo "=============================="
  echo

  # Parse arguments
  TOOLS="all"

  while [[ $# -gt 0 ]]; do
    case $1 in
      --tools)
        TOOLS="$2"
        shift 2
        ;;
      --help)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Run 'bash setup.sh --help' for usage information."
        exit 1
        ;;
    esac
  done

  # Verify prerequisites
  check_git_repo
  check_agents_md
  check_conventions_md

  # Setup based on tools argument
  IFS=',' read -ra TOOL_ARRAY <<< "$TOOLS"

  if [ "${#TOOL_ARRAY[@]}" -eq 1 ] && [ "${TOOL_ARRAY[0]}" = "all" ]; then
    setup_all_tools
  else
    for tool in "${TOOL_ARRAY[@]}"; do
      tool=$(echo "$tool" | xargs) # Trim whitespace
      case "$tool" in
        cursor)
          setup_cursor
          ;;
        claude)
          setup_claude
          ;;
        copilot)
          setup_copilot
          ;;
        windsurf)
          setup_windsurf
          ;;
        kiro)
          setup_kiro
          ;;
        *)
          print_warning "Unknown tool: $tool (skipping)"
          ;;
      esac
    done
  fi

  echo
  print_success "Setup complete!"
  echo
  echo "📋 Next steps:"
  echo "1. ✅ All AI tools now read from AGENTS.md"
  echo "2. 🔧 Customize CONVENTIONS.md for your team's stack"
  echo "3. 📝 Commit symlinks to git:"
  echo "     git add .cursorrules .claude.md .windsurfrules .github/ .cursor/ .kiro/"
  echo "     git commit -m 'chore: Configure AI tools to read shared AGENTS.md'"
  echo "4. 🚀 Start using! All tools see the same rules."
  echo
  echo "💡 Pro tip: Edit AGENTS.md once, all tools read the update instantly!"
  echo
}

# Run main
main "$@"
