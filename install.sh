#!/usr/bin/env bash

# ==============================================================================
# MURTIX AGENTIC WORKFLOW & ENVIRONMENT INSTALLER
# ==============================================================================
# This script automates the installation and configuration of the Murtix
# agentic development suite on a WSL2 / Ubuntu environment.
#
# It installs:
# 1. codebase-memory-mcp (Structural knowledge graph server from DeusData)
# 2. Amneshia (Long-term memory SQLite FTS5 graph server)
# 3. Seiza (Sub-agent orchestrator & task runner)
# 4. Rules & Directives (for Antigravity IDE and Seiza sub-agents)
# 5. Templates for mcp_config.json
#
# Designed to be modular, readable, and editable by other AI coding agents.
# Feel free to adjust variables below as needed for different device profiles.
# ==============================================================================

set -euo pipefail

# --- CONFIGURABLE PATHS & REPOS ---
PROJECTS_DIR="${HOME}/projects"
LOCAL_BIN_DIR="${HOME}/local-bin-tmp" # temporary directory if needed, otherwise using ~/.local/bin
AMNESHIA_REPO="https://github.com/SabilMurti/Amneshia.git"
SEIZA_REPO="https://github.com/SabilMurti/Seiza.git"
RULE_GEMINI_SOURCE="./rules/GEMINI.md"
RULE_SEIZA_SOURCE="./rules/SEIZA_RULES.md"

# Target directories on target device
GEMINI_RULES_DIR="${HOME}/.gemini"
GEMINI_CONFIG_DIR="${HOME}/.gemini/config"
SEIZA_RULES_DIR="${HOME}/.seiza"

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Murtix Agentic Env Installer ===${NC}"

# 1. Prerequisites Check
echo -e "${BLUE}[1/5] Checking prerequisites...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed. Please install Node.js (>= 18) first.${NC}"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install npm first.${NC}"
    exit 1
fi
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed. Please install git first.${NC}"
    exit 1
fi

NODE_PATH=$(which node)
NODE_BIN_DIR=$(dirname "$NODE_PATH")
echo -e "${GREEN}Detected Node.js at: $NODE_PATH${NC}"
echo -e "${GREEN}Node Bin Directory: $NODE_BIN_DIR${NC}"

# Create directories
mkdir -p "${PROJECTS_DIR}"
mkdir -p "${HOME}/.local/bin"
mkdir -p "${GEMINI_CONFIG_DIR}"
mkdir -p "${SEIZA_RULES_DIR}"

# 2. Install codebase-memory-mcp
echo -e "${BLUE}[2/5] Installing codebase-memory-mcp...${NC}"
if ! command -v codebase-memory-mcp &> /dev/null && [ ! -f "${HOME}/.local/bin/codebase-memory-mcp" ]; then
    echo "Downloading codebase-memory-mcp via DeusData official script..."
    # DeusData's official installer scripts download to ~/.local/bin/ by default
    curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
    echo -e "${GREEN}codebase-memory-mcp installed successfully.${NC}"
else
    echo -e "${GREEN}codebase-memory-mcp is already installed.${NC}"
fi

# 3. Clone and build Amneshia and Seiza
echo -e "${BLUE}[3/5] Cloning and building custom memory/agent tools...${NC}"

# Clone/Build Amneshia
if [ ! -d "${PROJECTS_DIR}/Amneshia" ]; then
    echo "Cloning Amneshia..."
    git clone "${AMNESHIA_REPO}" "${PROJECTS_DIR}/Amneshia"
else
    echo "Amneshia directory exists, pulling latest..."
    cd "${PROJECTS_DIR}/Amneshia" && git pull && cd -
fi
echo "Building Amneshia..."
cd "${PROJECTS_DIR}/Amneshia"
npm install
npm run build
# Install globally with --ignore-scripts to prevent re-triggering prepare hook
npm install -g . --ignore-scripts 2>&1 || echo -e "${RED}Non-critical warning: npm global install failed for Amneshia. mcp_config.json will use direct node path.${NC}"
cd -

# Clone/Build Seiza
if [ ! -d "${PROJECTS_DIR}/Seiza" ]; then
    echo "Cloning Seiza..."
    git clone "${SEIZA_REPO}" "${PROJECTS_DIR}/Seiza"
else
    echo "Seiza directory exists, pulling latest..."
    cd "${PROJECTS_DIR}/Seiza" && git pull && cd -
fi
echo "Building Seiza..."
cd "${PROJECTS_DIR}/Seiza"
npm install
# Build main server
npm run build
# Build dashboard if script exists
if npm run 2>/dev/null | grep -q "build:all"; then
    echo "Building Seiza dashboard..."
    npm run build:all
fi
# Install globally with --ignore-scripts to prevent re-triggering prepare/build hook
npm install -g . --ignore-scripts 2>&1 || echo -e "${RED}Non-critical warning: npm global install failed for Seiza. mcp_config.json will use direct node path.${NC}"
cd -

# 4. Copy Rules & Directives
echo -e "${BLUE}[4/5] Copying AI Agent Rules & Directives...${NC}"
if [ -f "${RULE_GEMINI_SOURCE}" ]; then
    cp "${RULE_GEMINI_SOURCE}" "${GEMINI_RULES_DIR}/GEMINI.md"
    echo -e "${GREEN}Copied Antigravity rules to ${GEMINI_RULES_DIR}/GEMINI.md${NC}"
else
    echo -e "${RED}Warning: ${RULE_GEMINI_SOURCE} not found. Skipping.${NC}"
fi

if [ -f "${RULE_SEIZA_SOURCE}" ]; then
    cp "${RULE_SEIZA_SOURCE}" "${SEIZA_RULES_DIR}/RULES.md"
    echo -e "${GREEN}Copied Seiza agent rules to ${SEIZA_RULES_DIR}/RULES.md${NC}"
else
    echo -e "${RED}Warning: ${RULE_SEIZA_SOURCE} not found. Skipping.${NC}"
fi

# 5. Configure mcp_config.json
echo -e "${BLUE}[5/5] Configuring mcp_config.json...${NC}"
TEMPLATE_FILE="./templates/mcp_config.json.template"
TARGET_CONFIG_FILE="${GEMINI_CONFIG_DIR}/mcp_config.json"

if [ ! -f "${TEMPLATE_FILE}" ]; then
    echo -e "${RED}Error: Template file ${TEMPLATE_FILE} not found.${NC}"
    exit 1
fi

# Ask for keys if they aren't already set in environment or existing config
CONTEXT7_API_KEY="${CONTEXT7_API_KEY:-}"
GITHUB_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"

# Try to extract existing keys if mcp_config.json exists
if [ -f "${TARGET_CONFIG_FILE}" ]; then
    echo "Backup existing config to ${TARGET_CONFIG_FILE}.bak"
    cp "${TARGET_CONFIG_FILE}" "${TARGET_CONFIG_FILE}.bak"
    
    # Simple extraction using node if available
    if [ -z "${CONTEXT7_API_KEY}" ]; then
        CONTEXT7_API_KEY=$(node -e "
            try {
                const cfg = require('${TARGET_CONFIG_FILE}');
                console.log(cfg.mcpServers.context7.headers.CONTEXT7_API_KEY || '');
            } catch(e) { console.log(''); }
        ")
    fi
    if [ -z "${GITHUB_TOKEN}" ]; then
        GITHUB_TOKEN=$(node -e "
            try {
                const cfg = require('${TARGET_CONFIG_FILE}');
                console.log(cfg.mcpServers['github-mcp-server'].args.find(a => a.startsWith('GITHUB_PERSONAL_ACCESS_TOKEN='))?.split('=')[1] || '');
            } catch(e) { console.log(''); }
        ")
    fi
fi

# If still empty, request from user or set placeholder
if [ -z "${CONTEXT7_API_KEY}" ]; then
    read -p "Enter Context7 API Key (press Enter to skip): " CONTEXT7_API_KEY </dev/tty || CONTEXT7_API_KEY=""
fi
if [ -z "${GITHUB_TOKEN}" ]; then
    read -p "Enter GitHub Personal Access Token (press Enter to skip): " GITHUB_TOKEN </dev/tty || GITHUB_TOKEN=""
fi

# Generate temporary filled config
TEMP_CONFIG=$(mktemp)
cat "${TEMPLATE_FILE}" | sed \
    -e "s|{{USER_HOME}}|${HOME}|g" \
    -e "s|{{NODE_BIN_DIR}}|${NODE_BIN_DIR}|g" \
    -e "s|{{CONTEXT7_API_KEY}}|${CONTEXT7_API_KEY}|g" \
    -e "s|{{GITHUB_PERSONAL_ACCESS_TOKEN}}|${GITHUB_TOKEN}|g" \
    > "${TEMP_CONFIG}"

# Perform a smart merge using node to prevent losing user's other custom MCP configs
node -e "
const fs = require('fs');
const targetPath = '${TARGET_CONFIG_FILE}';
const tempPath = '${TEMP_CONFIG}';

let existing = { mcpServers: {} };
if (fs.existsSync(targetPath)) {
  try {
    existing = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
  } catch (e) {
    console.error('Error reading existing config, writing fresh one:', e.message);
  }
}

const template = JSON.parse(fs.readFileSync(tempPath, 'utf8'));

// Merge servers: overwrite with template servers, keeping others intact
const merged = {
  ...existing,
  mcpServers: {
    ...existing.mcpServers,
    ...template.mcpServers
  }
};

fs.writeFileSync(targetPath, JSON.stringify(merged, null, 2));
console.log('Successfully merged MCP servers into ' + targetPath);
"

# Clean up temp file
rm -f "${TEMP_CONFIG}"

# Optional Amneshia/Seiza path patch if global npm linking failed
# We verify if global seiza/amneshia binaries exist. If not, we update mcp_config.json to run their dist/index.js directly.
node -e "
const fs = require('fs');
const targetPath = '${TARGET_CONFIG_FILE}';
if (fs.existsSync(targetPath)) {
  const cfg = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
  
  // Check amneshia
  const hasGlobalAmneshia = fs.existsSync('${NODE_BIN_DIR}/amneshia') || fs.existsSync('${HOME}/.local/bin/amneshia');
  if (!hasGlobalAmneshia) {
    console.log('Global amneshia binary not found. Patching mcp_config.json to call node directly on Amneshia source...');
    if (cfg.mcpServers.amneshia) {
      cfg.mcpServers.amneshia.args = [
        '-e',
        'env',
        'PATH=${NODE_BIN_DIR}:/usr/bin:/bin',
        '${NODE_BIN_DIR}/node',
        '${PROJECTS_DIR}/Amneshia/dist/index.js'
      ];
    }
  }

  // Check seiza
  const hasGlobalSeiza = fs.existsSync('${NODE_BIN_DIR}/seiza') || fs.existsSync('${HOME}/.local/bin/seiza');
  if (!hasGlobalSeiza) {
    console.log('Global seiza binary not found. Patching mcp_config.json to call node directly on Seiza source...');
    if (cfg.mcpServers.seiza) {
      cfg.mcpServers.seiza.args = [
        '-e',
        'env',
        'PATH=${NODE_BIN_DIR}:/usr/bin:/bin',
        '${NODE_BIN_DIR}/node',
        '${PROJECTS_DIR}/Seiza/dist/index.js'
      ];
    }
  }

  fs.writeFileSync(targetPath, JSON.stringify(cfg, null, 2));
}
"

echo -e "${GREEN}=== Installation Complete ===${NC}"
echo -e "${GREEN}Murtix Agentic Environment has been successfully configured!${NC}"
echo -e "${GREEN}Please reload your IDE/agent host to apply changes.${NC}"
