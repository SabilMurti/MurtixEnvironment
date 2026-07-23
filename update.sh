#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# MURTIX ENVIRONMENT UPDATE SCRIPT
# ==============================================================================
# Updates all core tools (Amneshia, Seiza, and codebase-memory-mcp) to their
# latest versions, then rebuilds them.
# ==============================================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Updating Murtix Agentic Environment   ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Update Amneshia
echo -e "${BLUE}[1/3] Updating Amneshia...${NC}"
if [ -d "${HOME}/projects/Amneshia" ]; then
    cd "${HOME}/projects/Amneshia"
    echo "Pulling latest changes..."
    git pull
    echo "Installing packages..."
    npm install
    echo "Rebuilding project..."
    npm run build
    echo -e "${GREEN}✓ Amneshia updated and built successfully.${NC}"
    cd - >/dev/null
else
    echo -e "${RED}✗ Amneshia directory not found at ~/projects/Amneshia. Skipping.${NC}"
fi
echo ""

# 2. Update Seiza
echo -e "${BLUE}[2/3] Updating Seiza...${NC}"
if [ -d "${HOME}/projects/Seiza" ]; then
    cd "${HOME}/projects/Seiza"
    echo "Pulling latest changes..."
    git pull
    echo "Installing packages..."
    npm install
    echo "Rebuilding project..."
    npm run build
    # Some versions of Seiza might require build:all if dashboard is present
    if npm run | grep -q "build:all"; then
        echo "Building Seiza dashboard..."
        npm run build:all
    fi
    echo -e "${GREEN}✓ Seiza updated and built successfully.${NC}"
    cd - >/dev/null
else
    echo -e "${RED}✗ Seiza directory not found at ~/projects/Seiza. Skipping.${NC}"
fi
echo ""

# 3. Update codebase-memory-mcp
echo -e "${BLUE}[3/3] Updating codebase-memory-mcp...${NC}"
if curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash; then
    echo -e "${GREEN}✓ codebase-memory-mcp updated successfully.${NC}"
else
    echo -e "${RED}✗ codebase-memory-mcp update failed.${NC}"
fi
echo ""

echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  Update cycle complete!${NC}"
echo -e "  Please run ${BLUE}./verify.sh${NC} to confirm everything is working."
echo -e "${BLUE}=====================================================${NC}"
