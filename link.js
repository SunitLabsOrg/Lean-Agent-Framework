const fs = require('fs');
const path = require('path');

// Usage: node link.js <target> <link_name>
// Example: node link.js AGENTS.md .cursorrules

const args = process.argv.slice(2);

if (args.length < 2) {
  console.error('Usage: node link.js <target> <link_name>');
  console.error('Example: node link.js AGENTS.md .cursorrules');
  process.exit(1);
}

const target = args[0];
const linkName = args[1];

const targetPath = path.resolve(process.cwd(), target);
const linkPath = path.resolve(process.cwd(), linkName);

// Ensure the target exists
if (!fs.existsSync(targetPath)) {
  console.error(`Error: Target file "${target}" does not exist.`);
  process.exit(1);
}

// Ensure the parent directory of the link exists
const linkDir = path.dirname(linkPath);
if (!fs.existsSync(linkDir)) {
  fs.mkdirSync(linkDir, { recursive: true });
}

// Remove the link if it already exists
if (fs.existsSync(linkPath) || fs.lstatSync(linkPath, { throwIfNoEntry: false })) {
  fs.rmSync(linkPath, { force: true });
}

try {
  // Create the symlink
  // 'file' type is used for Windows compatibility
  fs.symlinkSync(targetPath, linkPath, 'file');
  console.log(`✅ Successfully linked: ${linkName} -> ${target}`);
} catch (error) {
  console.error(`❌ Failed to create symlink: ${error.message}`);
  if (process.platform === 'win32') {
    console.error('On Windows, you may need to run this as Administrator or enable Developer Mode.');
  }
  process.exit(1);
}
