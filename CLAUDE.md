# CLAUDE.md - AI Assistant Guide for N8N

## Project Overview

This repository is an n8n project - a workflow automation platform. The codebase is currently in early setup phase.

**Status**: Initial setup (placeholder repository)

## Repository Structure

```
N8N/
├── README.md          # Project overview (stub)
├── CLAUDE.md          # This file - AI assistant guide
└── .git/              # Git repository
```

> **Note**: This repository is in its initial state. Update this section as the project structure evolves (e.g., when n8n source is added, custom nodes are built, or Docker configs are introduced).

## Development Setup

### Prerequisites

- Node.js (LTS recommended, check `.nvmrc` or `package.json` engines field when added)
- pnpm (n8n uses pnpm as its package manager)
- Git

### Getting Started

```bash
# Clone and install (once package.json is set up)
pnpm install

# Start development server (once configured)
pnpm dev
```

## Git Conventions

- **Default branch**: `main`
- **Remote**: `origin` → `thebardchat/N8N` on GitHub
- **Branch naming**: Use descriptive names like `feature/description`, `fix/description`, or `claude/description`
- **Commit messages**: Use conventional commits format - concise, imperative mood (e.g., "Add custom node for X", "Fix webhook handler timeout")

## Key Commands

> Update this section as the project build system is configured.

| Task | Command |
|------|---------|
| Install deps | `pnpm install` |
| Dev server | `pnpm dev` |
| Build | `pnpm build` |
| Test | `pnpm test` |
| Lint | `pnpm lint` |

## Coding Conventions

- **Language**: TypeScript (standard for n8n projects)
- **Style**: Follow existing linting/prettier config once added
- **Testing**: Write tests for custom nodes and workflow logic
- **Security**: Never commit secrets, API keys, or credentials. Use environment variables and `.env` files (gitignored)

## n8n-Specific Notes

### Custom Nodes

If this project includes custom n8n nodes:
- Place node files in a structured directory (e.g., `nodes/`)
- Each node needs a `.node.ts` file and corresponding `.credentials.ts` if auth is required
- Follow n8n's [node development docs](https://docs.n8n.io/integrations/creating-nodes/)

### Workflows

- Export workflows as JSON for version control
- Store workflow files in a dedicated directory (e.g., `workflows/`)
- Do not include credentials or sensitive data in exported workflows

## For AI Assistants

- Read this file first when starting work on this repository
- Check `package.json` (when it exists) for available scripts before suggesting commands
- Prefer editing existing files over creating new ones
- Keep changes minimal and focused on what was requested
- When the codebase grows, update this CLAUDE.md to reflect the current state
