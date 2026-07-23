#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# MURTIX ENVIRONMENT HEALTH CHECK
# ==============================================================================
# Verifies that all components of the agentic workspace are installed, built,
# and configured correctly.
# ==============================================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    FAIL=$((FAIL + 1))
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MurtixEnvironment Health Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Check codebase-memory-mcp
if command -v codebase-memory-mcp &>/dev/null; then
    check_pass "codebase-memory-mcp found in PATH"
elif [ -f "${HOME}/.local/bin/codebase-memory-mcp" ]; then
    check_pass "codebase-memory-mcp found at ~/.local/bin/codebase-memory-mcp"
else
    check_fail "codebase-memory-mcp not found (installing it is recommended)"
fi

# 2. Check Amneshia
if command -v amneshia &>/dev/null; then
    check_pass "Amneshia CLI command found in PATH"
elif [ -f "${HOME}/projects/Amneshia/dist/index.js" ]; then
    check_pass "Amneshia built at ~/projects/Amneshia/dist/index.js"
else
    check_fail "Amneshia not found or not built (clone to ~/projects/Amneshia and run npm run build)"
fi

# 3. Check Seiza
if command -v seiza &>/dev/null; then
    check_pass "Seiza CLI command found in PATH"
elif [ -f "${HOME}/projects/Seiza/dist/index.js" ]; then
    check_pass "Seiza built at ~/projects/Seiza/dist/index.js"
else
    check_fail "Seiza not found or not built (clone to ~/projects/Seiza and run npm run build)"
fi

# 4. Check MCP config
MCP_CONFIG_PATHS=(
    "${HOME}/.gemini/config/mcp_config.json"
    "${HOME}/.cursor/mcp.json"
    "${HOME}/.claude/claude_desktop_config.json"
    "${HOME}/.config/claude-code/config.json"
)

MCP_FOUND=false
for config_path in "${MCP_CONFIG_PATHS[@]}"; do
    if [ -f "${config_path}" ]; then
        # Check if it is a valid JSON
        if node -e "JSON.parse(require('fs').readFileSync('${config_path}', 'utf8'))" &>/dev/null; then
            check_pass "Valid MCP config found and verified at ${config_path}"
        else
            check_fail "MCP config found at ${config_path} but contains invalid JSON"
        fi
        MCP_FOUND=true
    fi
done

if [ "${MCP_FOUND}" = false ]; then
    check_fail "No MCP config files detected in common locations"
fi

# 5. Check GEMINI.md rules
if [ -f "${HOME}/.gemini/GEMINI.md" ]; then
    check_pass "GEMINI.md rules found at ~/.gemini/GEMINI.md"
else
    check_fail "GEMINI.md rules not found at ~/.gemini/GEMINI.md"
fi

# 6. Check SEIZA_RULES.md rules
if [ -f "${HOME}/.seiza/RULES.md" ]; then
    check_pass "SEIZA_RULES.md rules found at ~/.seiza/RULES.md"
else
    check_fail "SEIZA_RULES.md rules not found at ~/.seiza/RULES.md"
fi

# 7. Check Node.js version >= 18
if command -v node &>/dev/null; then
    NODE_VERSION=$(node -v | cut -d. -f1 | sed 's/v//')
    if [ "${NODE_VERSION}" -ge 18 ]; then
        check_pass "Node.js version is $(node -v) (>= 18 check passed)"
    else
        check_fail "Node.js version is $(node -v) (requires >= 18)"
    fi
else
    check_fail "Node.js not installed or not in PATH"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "  Health Check Summary: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo -e "${BLUE}========================================${NC}"

if [ "${FAIL}" -gt 0 ]; then
    exit 1
else
    exit 0
fi
