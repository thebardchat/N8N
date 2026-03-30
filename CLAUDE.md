# CLAUDE.md - AI Assistant Guide for N8N

## What This Is

This is the **n8n workflow automation hub** for the ShaneBrain ecosystem. It runs on **pulsar00100** and serves as the central nervous system connecting every service, bot, database, and application in the network.

n8n is not a side project here — it is the orchestration layer. Every automation, every data flow between services, every scheduled task routes through this.

**Status**: Ground-up build — starting from scratch, building it right.

## The Ecosystem This Connects

n8n on pulsar00100 ties into the entire thebardchat infrastructure:

### Core Services (shanebrain-core)
- **ShaneBrain Core** (`thebardchat/shanebrain-core`) — 9 services on Pi 5: Discord bot, RAG pipeline, voice pipeline, social automation, dispatch PWA
- **ShaneBrain MCP Server** (`thebardchat/shanebrain_mcp`) — Custom-built 27-tool MCP server for Weaviate RAG + Ollama. Knowledge, chat, vault, planning tools
- **Weaviate** — Vector database backing RAG and semantic search across the ecosystem
- **Ollama** — Local LLM inference

### Applications
- **Angel Cloud** (`thebardchat/angel-cloud`) — Mental wellness platform with AI sentiment analysis
- **HaloFinance** (`thebardchat/HaloFinance`) — AI-powered financial guidance for working families
- **Mini-ShaneBrain** (`thebardchat/mini-shanebrain`) — Social media automation bot
- **Thought Tree** (`thebardchat/thought-tree`) — React mind-mapping and brain-dump app

### Work/Operations
- **MASTER Scheduler Dashboard** (`thebardchat/MASTER-Scheduler-Dashboard-SRM`) — SRM Concrete dispatch: 16 drivers, 19 plants, block plant priority routing
- **SB-Management-OS** (`thebardchat/SB-Management-OS`) — SOPs, coaching scripts, personnel management
- **SRM Dispatch** (`thebardchat/srm-dispatch`) — Daily dispatch PWA for route planning

### Security & Infrastructure
- **Pulsar Sentinel** (`thebardchat/pulsar_sentinel`) — Post-quantum cryptography security framework (ML-KEM, blockchain audit trails)
- **ShaneBrain Backup** (`thebardchat/shanebrain-backup`) — Backup systems

### Discord Bots
- Integrated into shanebrain-core
- n8n will handle webhook routing, event triggers, and automated responses

### Content & Creative
- **AI-Trainer-MAX** (`thebardchat/AI-Trainer-MAX`) — 36-module AI training curriculum
- **Book projects** — Publishing pipeline and launch playbooks
- **Angel Cloud Roblox** (`thebardchat/angel-cloud-roblox`) — Lua-based Roblox integration

## Architecture

```
pulsar00100 (host machine)
├── n8n (THIS REPO — workflow orchestration)
│   ├── Webhooks & triggers
│   ├── Scheduled automations
│   ├── Service-to-service routing
│   └── Custom nodes (as needed)
│
├── shanebrain-core (9 services)
│   ├── Discord bot
│   ├── RAG pipeline
│   ├── Voice pipeline
│   └── Social automation
│
├── shanebrain_mcp (27-tool MCP server)
│   ├── Weaviate RAG tools
│   ├── Ollama inference
│   ├── Vault / knowledge store
│   └── Planning tools
│
├── Weaviate (vector DB)
├── Ollama (local LLM)
└── Supporting services (Angel Cloud, HaloFinance, etc.)
```

## Repository Structure

> This will grow as we build. Update this section as files are added.

```
N8N/
├── CLAUDE.md          # This file — the source of truth for AI assistants
├── README.md          # Project overview
└── (to be built)
```

### Planned Structure
```
N8N/
├── docker-compose.yml     # n8n + dependencies
├── .env.example           # Environment variable template (no secrets)
├── workflows/             # Exported n8n workflow JSON files
├── custom-nodes/          # Custom n8n nodes for ShaneBrain services
├── credentials/           # Credential type definitions (no actual secrets)
├── scripts/               # Setup, backup, maintenance scripts
├── docs/                  # Architecture decisions, integration guides
├── CLAUDE.md
└── README.md
```

## Development Setup

### Host Machine
- **Machine**: pulsar00100
- **Stack**: Docker-based (n8n runs in containers)
- **Network**: Local home network connecting all services

### Prerequisites
- Docker & Docker Compose
- Node.js (LTS) — for custom node development
- pnpm — package manager for Node.js projects
- Git
- Access to pulsar00100's local network

### Getting Started
```bash
# 1. Clone the repo
git clone https://github.com/thebardchat/N8N.git
cd N8N

# 2. Copy environment template
cp .env.example .env
# Edit .env with actual values

# 3. Start n8n
docker-compose up -d

# 4. Access n8n UI
# http://pulsar00100:5678 (or configured port)
```

## n8n Integration Points

These are the key connections n8n will manage:

| Service | Connection Type | Purpose |
|---------|----------------|---------|
| ShaneBrain MCP | HTTP/REST | Trigger MCP tools, query Weaviate via RAG |
| Weaviate | REST API | Direct vector DB queries, data ingestion |
| Ollama | REST API (port 11434) | Local LLM inference for workflow logic |
| Discord | Webhooks + Bot API | Event triggers, automated messages, bot commands |
| Angel Cloud | REST API | Wellness check-ins, sentiment data flows |
| HaloFinance | REST API | Financial data processing, alerts |
| SRM Dispatch | REST/Webhooks | Dispatch events, driver assignments, scheduling |
| GitHub | Webhooks + API | Repo events, CI triggers, issue automation |

## Git Conventions

- **Default branch**: `main`
- **Remote**: `origin` → `thebardchat/N8N`
- **Branch naming**: `feature/description`, `fix/description`, `claude/description`
- **Commit messages**: Conventional commits, imperative mood. Be specific about which integration or service is affected (e.g., "Add Discord webhook trigger for daily dispatch summary")

## Coding Conventions

- **Language**: TypeScript for custom nodes, Python where ShaneBrain services are involved
- **Config**: Environment variables for all secrets and connection strings. Never hardcode
- **Workflows**: Export as JSON, store in `workflows/` directory with descriptive names
- **Custom Nodes**: Follow n8n node development patterns. One node per integration where possible
- **Security**: No secrets in git. Use `.env` files (gitignored). Pulsar Sentinel standards apply
- **Docker**: All services containerized. Use docker-compose for local orchestration

## For AI Assistants

### Critical Rules
1. **Read this file first** when starting any work session
2. **This connects to everything** — changes here can affect the entire ecosystem. Understand the integration point before modifying
3. **No secrets in code** — ever. Use environment variables
4. **Test locally** before pushing workflow changes
5. **Workflow JSON files are source of truth** — always export and commit after changes

### Cross-Repo Context
When working on n8n integrations, you may need to reference:
- `thebardchat/shanebrain-core` — for understanding service endpoints and data formats
- `thebardchat/shanebrain_mcp` — for MCP tool definitions and Weaviate schema
- `thebardchat/angel-cloud` — for Angel Cloud API endpoints
- `thebardchat/HaloFinance` — for financial data schemas
- `thebardchat/MASTER-Scheduler-Dashboard-SRM` — for dispatch data structures

### When Adding New Integrations
1. Document the service connection in the integration table above
2. Create environment variables for all connection details
3. Build a test workflow first before production flows
4. Export the workflow JSON and commit it
5. Update this CLAUDE.md with any new architectural context

### The Constitution
The ShaneBrain ecosystem operates under a governing covenant (`thebardchat/constitution`). Faith, family, local AI, the left-behind user. Every tool built here serves that mission.
