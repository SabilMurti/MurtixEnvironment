# MurtixEnvironment — AI Agent Installation Prompt

Copy and paste the prompt below into your AI coding agent (Claude Code, Cursor, Antigravity IDE, Aider, Windsurf, etc.) to have it automatically configure the MurtixEnvironment on your system.

---

## Installation Prompt

```text
I need you to install and configure the MurtixEnvironment agentic developer workspace on my system.

Here is the repository: https://github.com/SabilMurti/MurtixEnvironment

Follow these steps carefully:

## Step 1: Clone the repository
Clone https://github.com/SabilMurti/MurtixEnvironment.git into a working directory (e.g. ~/projects/MurtixEnvironment or wherever my projects live).

## Step 2: Read and understand the install script
Read the `install.sh` file in the cloned repository. Understand what it does — it installs three core MCP servers (codebase-memory-mcp, Amneshia, Seiza), copies agent rule files, and configures MCP server entries.

## Step 3: Check system prerequisites
Before running anything, verify that these are installed on my system:
- Node.js (>= 18) — check with `node --version`
- npm — check with `npm --version`
- git — check with `git --version`
- curl — check with `curl --version`

If any are missing, install them first using the appropriate package manager for my OS.

## Step 4: Run the installer
Run `chmod +x install.sh && ./install.sh` from within the cloned MurtixEnvironment directory.

If the script encounters any errors due to path differences on my system, do NOT just report the error. Instead:
- Read the error message carefully.
- Identify the root cause (e.g. different Node.js path, missing directory, permission issue).
- Either edit `install.sh` to fix the path for my system, or run the equivalent commands manually.
- Continue until all 5 steps of the installer complete successfully.

## Step 5: Detect and configure MCP config files
This is the most important step. Different IDEs and AI tools store their MCP configuration in different locations. You need to find ALL of them on my system and update each one.

Search for MCP configuration files in these common locations:
- `~/.gemini/config/mcp_config.json` (Antigravity IDE / Gemini CLI on WSL)
- `~/.cursor/mcp.json` (Cursor IDE)
- `~/.claude/claude_desktop_config.json` (Claude Desktop)
- `~/.config/claude-code/config.json` (Claude Code CLI)
- `~/.codeium/windsurf/mcp_config.json` (Windsurf)
- `~/.continue/config.json` (Continue.dev)
- Any other MCP config files you can find by searching: `find ~ -maxdepth 4 -name "*mcp*config*" -o -name "*mcp*.json" 2>/dev/null`

For EACH config file you find:
1. Back it up first (copy to .bak).
2. Read the template from `templates/mcp_config.json.template` in the cloned repo.
3. Replace the template placeholders with values appropriate for MY system:
   - `{{USER_HOME}}` → my actual home directory path
   - `{{NODE_BIN_DIR}}` → the directory containing my `node` binary (run `dirname $(which node)`)
   - `{{CONTEXT7_API_KEY}}` → ask me for this, or leave empty string if I don't have one
   - `{{GITHUB_PERSONAL_ACCESS_TOKEN}}` → ask me for this, or leave empty string if I don't have one
4. IMPORTANT: Do a smart merge — add the new MCP server entries WITHOUT removing any existing MCP servers the user already has configured. Only overwrite entries with matching keys (e.g. if "amneshia" already exists, update it; if "my-custom-server" exists, leave it alone).
5. Verify the resulting JSON is valid.

Also check if the config file format differs per IDE. Some use `"mcpServers": {}` while others use a different schema. Adapt the server entries to match the format of each specific config file.

## Step 6: Copy agent rules
The installer should have already done this, but verify:
- `rules/GEMINI.md` from the repo should be copied to `~/.gemini/GEMINI.md`
- `rules/SEIZA_RULES.md` from the repo should be copied to `~/.seiza/RULES.md`

If the directories don't exist, create them.

## Step 7: Verify installation
After everything is done, verify that:
- `codebase-memory-mcp` binary exists (check `which codebase-memory-mcp` or `ls ~/.local/bin/codebase-memory-mcp`)
- Amneshia is built: `ls ~/projects/Amneshia/dist/index.js` (or wherever it was cloned)
- Seiza is built: `ls ~/projects/Seiza/dist/index.js` (or wherever it was cloned)
- MCP config files have been updated with the new server entries
- Rule files have been copied to their target locations

Report a summary of what was installed, what configs were updated, and any issues encountered.
```

---

## Notes

- The prompt is designed to be device-agnostic. The AI agent will dynamically detect paths, config file locations, and system differences on the target machine.
- If your IDE or tool uses a different MCP config format or location, the AI agent is instructed to adapt accordingly.
- You can modify this prompt to skip optional components (e.g. remove the GitHub MCP server if you don't need it).
