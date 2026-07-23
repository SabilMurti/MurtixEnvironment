# 🧠 MurtixEnvironment

A shareable, reproducible WSL2 agentic developer workspace. Clone this repo and let your AI coding agent configure everything automatically — or run the installer manually.

This environment splits the development process into two layers: **Planning & Orchestration** (handled by your IDE agent — Antigravity IDE, Cursor, Claude Code, etc.) and **Parallel Execution** (handled by Seiza sub-agents). All agents share a unified long-term memory ([Amneshia](https://github.com/SabilMurti/Amneshia)) and a graph-based codebase index ([codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)).

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    PLANNING LAYER                            │
│                                                              │
│   Antigravity IDE  ·  Cursor  ·  Claude Code  ·  OMP (CLI)  │
│          ↓ run_seiza_task / run_single_agent                 │
├──────────────────────────────────────────────────────────────┤
│                   EXECUTION LAYER                            │
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │                  Seiza Orchestrator                   │   │
│   │   ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌─────────┐  │   │
│   │   │  Coder  │ │ Reviewer │ │ Planner │ │ Tester  │  │   │
│   │   └────┬────┘ └────┬─────┘ └────┬────┘ └────┬────┘  │   │
│   └────────┼───────────┼────────────┼───────────┼────────┘   │
│            │           │            │           │            │
├────────────┼───────────┼────────────┼───────────┼────────────┤
│                   MEMORY & CONTEXT LAYER                     │
│                                                              │
│   Amneshia          codebase-memory-mcp       Context7       │
│   (Long-term        (Tree-Sitter code         (Live library  │
│    memory graph)     knowledge graph)          documentation) │
│                                                              │
│                      9router                                 │
│                 (Free model fallback)                         │
└──────────────────────────────────────────────────────────────┘
```

### Workflow Option A: IDE Agent + Seiza

Your IDE's AI agent (Antigravity IDE, Cursor, Claude Code, etc.) acts as the **project manager** — it understands the request, creates an implementation plan, and gets your approval. Then it delegates the actual coding to **Seiza** via `run_seiza_task`. Seiza splits the work into a DAG of parallel sub-tasks executed by specialized agents (coder, reviewer, planner, tester).

### Workflow Option B: OMP + Seiza (CLI-First)

**OMP (Oh My Pi)** is a CLI-based orchestrator that does the same thing from the terminal. It decomposes complex tasks and delegates them to Seiza sub-agents. This is useful for headless environments or automation pipelines.

---

## What's Included

### Core MCP Servers

| Tool | What It Does | Key Benefit |
|:---|:---|:---|
| **[Seiza](https://github.com/SabilMurti/Seiza)** | Hub-and-spoke sub-agent orchestrator | Splits heavy tasks into parallel sub-agents (coder, reviewer, planner, tester). Eliminates single-agent bottlenecks. |
| **[Amneshia](https://github.com/SabilMurti/Amneshia)** | SQLite FTS5 long-term memory & knowledge graph | Persists user preferences, architectural decisions, project context, and entity relationships across all sessions. 18 MCP tools. |
| **[codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)** | Tree-Sitter codebase knowledge graph | Indexes your entire codebase into a queryable graph. **Reduces agent token consumption by 80–95%** vs. raw file scanning. Single static C binary, zero dependencies. |
| **[Context7](https://context7.com)** | Live official documentation engine | Fetches the latest docs for React, Next.js, Laravel, Tailwind, etc. in real-time. Prevents hallucinated API calls and outdated syntax. |
| **[Sequential Thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)** | Multi-step reasoning tool | Forces the agent to think step-by-step, evaluate hypotheses, and plan before writing code. |

### Also Included (Optional)

| Tool | What It Does |
|:---|:---|
| **OMP (Oh My Pi)** | CLI-based parallel execution orchestrator (alternative to IDE-based planning) |
| **9router** | Local model router daemon — automatically routes LLM requests to free models (e.g. `gemini-3-flash`) as fallback before using paid models |
| **GitHub MCP Server** | GitHub API integration (issues, PRs, file operations) via MCP |
| **ESLint MCP** | Real-time linting integration |

### Agent Rules & Directives

| File | Purpose |
|:---|:---|
| `rules/GEMINI.md` | Core directives for the planning-layer agent (Antigravity IDE / Gemini). Defines the full MCP-first workflow, security standards, professional engineering standards, and fallback model handling. |
| `rules/SEIZA_RULES.md` | Directives for Seiza sub-agents. Enforces MCP-first code discovery, zero-placeholder policy, library-over-reinvention, and security-by-default. |

---

## Quick Install (Let Your AI Do It)

The fastest way to set this up on a new machine is to let your AI coding agent handle it.

👉 **[Read the full AI Installation Prompt →](./INSTALL_PROMPT.md)**

Copy the prompt from that file and paste it into your AI agent. It will:
1. Clone this repo
2. Install all dependencies (codebase-memory-mcp, Amneshia, Seiza)
3. Detect where your IDE stores its MCP config and update it automatically
4. Copy the agent rule files to the correct locations
5. Handle any path differences or errors on your specific system

---

## Manual Install

### Prerequisites

- **WSL2 / Ubuntu** (or any Linux environment)
- **Node.js** >= 18
- **npm**, **git**, **curl**

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/SabilMurti/MurtixEnvironment.git
cd MurtixEnvironment

# 2. Run the installer
chmod +x install.sh
./install.sh
```

The installer will:

1. **Check prerequisites** — verifies `node`, `npm`, `git` are available and detects paths automatically.
2. **Install codebase-memory-mcp** — downloads the static binary from [DeusData's official installer](https://github.com/DeusData/codebase-memory-mcp) to `~/.local/bin/`.
3. **Clone & build Amneshia** — from `https://github.com/SabilMurti/Amneshia.git` into `~/projects/Amneshia`, runs `npm install && npm run build`, and registers the global binary.
4. **Clone & build Seiza** — from `https://github.com/SabilMurti/Seiza.git` into `~/projects/Seiza`, runs `npm install && npm run build`, and registers the global binary.
5. **Copy agent rules** — places `GEMINI.md` into `~/.gemini/` and `SEIZA_RULES.md` into `~/.seiza/`.
6. **Configure MCP** — reads `templates/mcp_config.json.template`, substitutes your system paths, and performs a **smart merge** into `~/.gemini/config/mcp_config.json` (preserving any existing MCP servers you already have configured).

### Post-Install: MCP Bridge Setup

After installation, Amneshia and Seiza support **MCP Bridge** connections to `codebase-memory-mcp`. This allows:
- **Amneshia** to store codebase structural metadata in its long-term memory graph.
- **Seiza** sub-agents to query code structure directly via bridged tools instead of scanning files.

The bridge is configured automatically when the tools detect each other in the MCP config.

## Post-Install Verification

After running `install.sh`, verify everything is working:

```bash
./verify.sh
```

Example output when all checks pass:

```
========================================
  MurtixEnvironment Health Check
========================================

✓ codebase-memory-mcp found at ~/.local/bin/codebase-memory-mcp
✓ Amneshia found at ~/projects/Amneshia/dist/index.js
✓ Seiza found at ~/projects/Seiza/dist/index.js
✓ Valid MCP config found at ~/.gemini/config/mcp_config.json
✓ GEMINI.md found at ~/.gemini/GEMINI.md
✓ RULES.md found at ~/.seiza/RULES.md
✓ Node.js v20.11.0 (>= 18)

  Summary: 7 passed, 0 failed
========================================
```

---

## Updating

To update all tools to their latest versions, run:

```bash
./update.sh
```

This updates Amneshia, Seiza, and codebase-memory-mcp to their latest releases. Run `./verify.sh` afterwards to confirm everything still works.

---

## Troubleshooting

### Node.js version too old

Requires Node.js >= 18. Install a newer version with `fnm`:

```bash
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 20 && fnm use 20
```

### `npm install -g` or `npm link` fails with EACCES

```bash
npm config set prefix ~/.local
export PATH="$HOME/.local/bin:$PATH"
```

### `codebase-memory-mcp` download fails

Download the binary manually from [github.com/DeusData/codebase-memory-mcp/releases](https://github.com/DeusData/codebase-memory-mcp/releases), place it at `~/.local/bin/codebase-memory-mcp`, then run `chmod +x ~/.local/bin/codebase-memory-mcp`.

### MCP config not detected by IDE

Different IDEs store configs in different locations. See [INSTALL_PROMPT.md](./INSTALL_PROMPT.md) for a full list of known paths and how to update each one.

### Amneshia or Seiza MCP server fails to start

1. Check `dist/index.js` exists: `ls ~/projects/Amneshia/dist/index.js`
2. If missing, rebuild: `cd ~/projects/Amneshia && npm run build`
3. Verify the Node.js path in your MCP config: `which node` — the path must match what is in the config.

---

## Repository Structure

```
MurtixEnvironment/
├── README.md                               # This file
├── INSTALL_PROMPT.md                       # AI agent installation prompt
├── install.sh                              # Automated installer script
├── verify.sh                               # Post-install health-check
├── update.sh                               # Update all tools to latest
├── .env.example                            # API keys template
├── .gitignore
├── LICENSE                                 # MIT
├── rules/
│   ├── GEMINI.md                           # Antigravity IDE agent directives
│   └── SEIZA_RULES.md                      # Seiza sub-agent directives
└── templates/
    └── mcp_config.json.template            # Parameterized MCP config template
```

---

## Customization

The `install.sh` script is designed to be **readable and editable by AI agents**. If something doesn't work on your system:
- Ask your AI agent to read the script, understand the issue, and fix it.
- All configurable paths are at the top of the script as shell variables.
- The MCP config template uses simple `{{PLACEHOLDER}}` syntax that can be adapted for any path layout.

---

*Built by [Murtix](https://github.com/SabilMurti) — for efficient, agentic development.*
