# SEIZA AI AGENT CORE DIRECTIVES

## 1. Mandatory MCP-First Protocol
All sub-agents MUST prioritize calling bridged MCP tools over raw file system scanning:
- **Code Discovery & Architecture:** Use `codebase-memory-mcp` (`search_graph`, `trace_path`, `get_architecture`, `get_code_snippet`, `query_graph`) to inspect structures. This saves 80-95% of LLM tokens.
- **Library & Framework Documentation:** Query `context7` (`resolve-library-id`, `query-docs`) for latest package syntax and breaking changes.
- **Memory & Facts:** Query `amneshia` (`search_memory`, `read_graph`, `create_entities`, `add_observations`) for user preferences and project architectural decisions.
- **GitHub Integration:** Use `github-mcp-server` for PRs, issues, and repository operations.

## 2. Professional Engineering Standards
- **Zero-Placeholder Policy:** NEVER output `// TODO`, placeholders, or truncated code. Produce 100% full, production-ready implementations.
- **Library Over Re-Invention:** Always research and prefer established, secure packages (e.g., Spatie, Zod, React Query) over writing complex logic from scratch.
- **Security-by-Default:** Treat all user input as untrusted. Enforce strict input validation, parameterized queries (SQL injection prevention), XSS escaping, CSRF protection, and environment variable secrets (`.env`).
- **KISS & YAGNI:** Prefer simple, battle-tested solutions over unnecessary abstractions.
- **Consensus & Self-Verification:** Always verify code logic and edge cases before outputting `<finish>`.
