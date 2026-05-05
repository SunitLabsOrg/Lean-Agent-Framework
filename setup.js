const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colors for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function printStatus(msg) {
  console.log(`${colors.blue}[INFO]${colors.reset} ${msg}`);
}

function printSuccess(msg) {
  console.log(`${colors.green}[SUCCESS]${colors.reset} ${msg}`);
}

function printWarning(msg) {
  console.log(`${colors.yellow}[WARNING]${colors.reset} ${msg}`);
}

function printError(msg) {
  console.error(`${colors.red}[ERROR]${colors.reset} ${msg}`);
}

function showHelp() {
  console.log(`
${colors.magenta}Lean Agent Framework Setup Script (Node.js)${colors.reset}
===========================================

Usage: node setup.js [--tools TOOLS] [--help]

Options:
  --tools TOOLS      Comma-separated list of tools to configure
                     Valid: cursor, claude, copilot, windsurf, kiro, all (default: all)
  --help             Show this help message

Prerequisites:
  On Windows, run your terminal as Administrator or enable Developer Mode so
  symlinks can be created successfully.

Examples:
  node setup.js
  node setup.js --tools cursor,claude,copilot
  node setup.js --tools cursor
  node setup.js --help

After setup:
  1. Verify AGENTS.md is in your project root
  2. Customize CONVENTIONS.md for your team's stack
  3. Commit link files to git: git add .cursorrules .claude.md .windsurfrules etc.
  4. Start using with your AI tools - they'll all read the same AGENTS.md!
`);
}

function checkAgentsMd() {
  if (!fs.existsSync('AGENTS.md')) {
    printError('AGENTS.md not found in current directory. Please copy it first:');
    console.log('  cp .laf/AGENTS.md .');
    process.exit(1);
  }
}

function checkConventionsMd() {
  if (!fs.existsSync('CONVENTIONS.md')) {
    printWarning('CONVENTIONS.md not found. Creating from template...');
    if (fs.existsSync(path.join('.laf', 'CONVENTIONS.md'))) {
      fs.copyFileSync(path.join('.laf', 'CONVENTIONS.md'), 'CONVENTIONS.md');
      printSuccess('CONVENTIONS.md created. Please customize it.');
    } else {
      printError('Could not find CONVENTIONS.md template.');
      process.exit(1);
    }
  }
}

function createSymlink(targetRelativePath, linkPath) {
  const fullLinkPath = path.resolve(process.cwd(), linkPath);
  const linkDir = path.dirname(fullLinkPath);

  if (!fs.existsSync(linkDir)) {
    fs.mkdirSync(linkDir, { recursive: true });
  }

  if (fs.existsSync(fullLinkPath) || fs.lstatSync(fullLinkPath, { throwIfNoEntry: false })) {
    fs.rmSync(fullLinkPath, { force: true });
  }

  try {
    // We use the relative target string directly so the symlink is portable in Git
    fs.symlinkSync(targetRelativePath, fullLinkPath, 'file');
    return true;
  } catch (error) {
    printError(`Could not create symlink: ${linkPath} -> ${targetRelativePath}`);
    if (process.platform === 'win32') {
      printError('Symlink creation requires Administrator privileges or Windows Developer Mode.');
      printError('Re-run your terminal as Administrator, or enable Developer Mode, then try again.');
    } else {
      printError(error.message);
    }
    process.exit(1);
  }
}

const toolsConfig = {
  cursor: () => {
    printStatus('Setting up Cursor...');
    createSymlink('../AGENTS.md', '.cursor/rules.md');
    createSymlink('AGENTS.md', '.cursorrules');
    printSuccess('✓ Cursor configured');
  },
  claude: () => {
    printStatus('Setting up Claude Code...');
    createSymlink('AGENTS.md', '.claude.md');
    printSuccess('✓ Claude Code configured');
  },
  copilot: () => {
    printStatus('Setting up GitHub Copilot...');
    createSymlink('../AGENTS.md', '.github/copilot-instructions.md');
    printSuccess('✓ GitHub Copilot configured');
  },
  windsurf: () => {
    printStatus('Setting up Windsurf...');
    createSymlink('AGENTS.md', '.windsurfrules');
    printSuccess('✓ Windsurf configured');
  },
  kiro: () => {
    printStatus('Setting up Kiro...');
    createSymlink('../../AGENTS.md', '.kiro/steering/agents.md');
    printSuccess('✓ Kiro configured');
  },
  gemini: () => {
    printStatus('Setting up Gemini...');
    createSymlink('AGENTS.md', 'gemini-rules.md');
    printSuccess('✓ Gemini configured');
  }
};

function main() {
  console.log(`\n${colors.magenta}🤖 Lean Agent Framework Setup${colors.reset}`);
  console.log(`${colors.magenta}==============================${colors.reset}\n`);

  const args = process.argv.slice(2);
  let toolsArg = 'all';

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--help') {
      showHelp();
      process.exit(0);
    } else if (args[i] === '--tools' && args[i + 1]) {
      toolsArg = args[i + 1];
      i++;
    }
  }

  checkAgentsMd();
  checkConventionsMd();

  const requestedTools = toolsArg === 'all' 
    ? Object.keys(toolsConfig) 
    : toolsArg.split(',').map(t => t.trim().toLowerCase());

  for (const tool of requestedTools) {
    if (toolsConfig[tool]) {
      toolsConfig[tool]();
    } else {
      printWarning(`Unknown tool: ${tool} (skipping)`);
    }
  }

  console.log(`\n${colors.green}[SUCCESS] Setup complete!${colors.reset}\n`);
  console.log(`${colors.cyan}📋 Next steps:${colors.reset}`);
  console.log('1. ✅ All AI tools now read from AGENTS.md');
  console.log('2. 🔧 Customize CONVENTIONS.md for your team\'s stack');
  console.log('3. 📝 Commit symlinks to git:');
  console.log('     git add .cursorrules .claude.md .windsurfrules .github/ .cursor/ .kiro/ gemini-rules.md');
  console.log('     git commit -m "chore: Configure AI tools to read shared AGENTS.md"');
  console.log('4. 🚀 Start using! All tools see the same rules.\n');
  console.log(`${colors.yellow}💡 Pro tip: Edit AGENTS.md once, all tools read the update instantly!${colors.reset}\n`);
}

main();
