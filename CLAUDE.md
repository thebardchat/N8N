# CLAUDE.md - AI Assistant Guide for N8N

## What This Is

**n8n workflow automation hub** on **Pulsar0100**. Central nervous system for the ShaneBrain ecosystem. Every automation, every data flow, every scheduled task routes through here.

**Status**: Ground-up build — Step 1: Get n8n running on Pulsar.

## Who You're Working With

Shane Brazelton. Dispatch Manager, Hazel Green AL. ADHD brain. Zero fluff. Direct answers only. Short blocks, checkboxes, no preamble. If there's a way to do it, say YES and show the path.

## The Cluster

### Node 1: Raspberry Pi 5 (shanebrain-core)
- **Hardware**: Pi 5 16GB, Pironman 5-MAX case, RAID 1 NVMe mirrored storage
- **Tailscale IP**: `100.67.120.6`
- **Local IP**: `10.0.0.42`
- **SSH**: `shanebrain@100.67.120.6` port 22
- **Working dir**: `/mnt/shanebrain-raid/shanebrain-core/`
- **Services running**:
  - Ollama (llama3.2:1b, llama3.2:3b, nomic-embed-text, shanebrain-3b)
  - Weaviate: ports `8080` (REST) / `50051` (gRPC)
  - Open WebUI: port `3000`
  - FastMCP: port `8008` (27 tools)
  - Portainer, Redis
  - Claude Code v2.1.37

### Node 2: Pulsar0100 (THIS MACHINE — n8n host)
- **OS**: Windows
- **Tailscale IP**: `100.81.70.117`
- **Username**: `administrator`
- **Role**: Runs n8n on port `5678`. Stays lean — no AI workloads
- **SSH**: Pi's ed25519 key trusted. Keys go in `C:\ProgramData\ssh\administrators_authorized_keys`

### Node 3: Laptop
- **Name**: `laptop-ts6v7fna`
- **Tailscale IP**: `100.94.122.125`

### Unidentified Node
- **Name**: `bullfrog-max-r2d2`
- **Tailscale IP**: `100.87.222.17`
- **Status**: Flagged for later investigation

### Networking Rules
- **Always use Tailscale IPs directly. Never MagicDNS.**
- Pi is the master key holder for SSH
- Pi → Pulsar: passwordless SSH works
- Phone → Pi: works via Terminus app
- Phone → Pulsar: not yet (phone pubkey not in Pulsar's authorized_keys). Workaround: phone → Pi → Pulsar

## The Pipeline

```
Phone → N8N webhook (Pulsar:5678) → MCP server (Pi:8008) → Ollama embed (nomic-embed-text) → Weaviate store (Pi:8080) → Response back to phone
```

Pulsar stays lean. Pi does all AI heavy lifting. One network hop Pulsar→Pi is negligible on Tailscale.

## Build Order

- [ ] **Step 1**: Install n8n on Pulsar0100, confirm running on port 5678
- [ ] **Step 2**: Verify n8n can reach Pi MCP at `100.67.120.6:8008`
- [ ] **Step 3**: Verify n8n can reach Weaviate at `100.67.120.6:8080`
- [ ] **Step 4**: Build skeleton webhook workflow (phone → MCP → embed → Weaviate store)
- [ ] **Step 5**: Test end-to-end
- [ ] **Step 6**: Layer use-case workflows on top

### First Move
```bash
# From Pi, SSH into Pulsar
ssh administrator@100.81.70.117

# On Pulsar, install n8n globally
npm install -g n8n

# Start n8n on port 5678
n8n start --port 5678
```

### Future Workflows (after skeleton)
- Dispatch operations automation
- Book tracking
- Bill alerts
- Alexa integration
- IEP advocacy tools

## Architecture

```
Pulsar0100 (Windows — n8n host)
├── n8n on port 5678
│   ├── Webhook endpoints (phone, services)
│   ├── HTTP calls to Pi MCP (100.67.120.6:8008)
│   ├── HTTP calls to Weaviate (100.67.120.6:8080)
│   └── Scheduled automations
│
Pi 5 (shanebrain-core — AI heavy lifter)
├── FastMCP server (port 8008, 27 tools)
├── Ollama (llama3.2:1b/3b, nomic-embed-text, shanebrain-3b)
├── Weaviate (port 8080/50051)
├── Open WebUI (port 3000)
├── Discord bot, RAG pipeline, voice pipeline
├── Redis, Portainer
└── Claude Code
```

## Connected Ecosystem (thebardchat repos)

### Core
| Repo | What |
|------|------|
| `shanebrain-core` | 9 services on Pi 5: Discord bot, RAG, voice, social automation, dispatch |
| `shanebrain_mcp` | 27-tool MCP server for Weaviate RAG + Ollama |

### Applications
| Repo | What |
|------|------|
| `angel-cloud` | Mental wellness platform, AI sentiment analysis |
| `HaloFinance` | AI-powered financial guidance for working families |
| `mini-shanebrain` | Social media automation bot |
| `thought-tree` | React mind-mapping app |

### Work/Operations
| Repo | What |
|------|------|
| `MASTER-Scheduler-Dashboard-SRM` | SRM Concrete dispatch: 16 drivers, 19 plants |
| `SB-Management-OS` | SOPs, coaching scripts, personnel management |
| `srm-dispatch` | Daily dispatch PWA for route planning |

### Security & Infrastructure
| Repo | What |
|------|------|
| `pulsar_sentinel` | Post-quantum crypto security framework |
| `shanebrain-backup` | Backup systems |

### Content
| Repo | What |
|------|------|
| `AI-Trainer-MAX` | 36-module AI training curriculum |
| `angel-cloud-roblox` | Lua-based Roblox integration |
| `book-launch-playbook` | Publishing pipeline |

## n8n Integration Points

| Service | Endpoint | Purpose |
|---------|----------|---------|
| ShaneBrain MCP | `100.67.120.6:8008` | Trigger MCP tools, query RAG |
| Weaviate | `100.67.120.6:8080` | Vector DB queries, data ingestion |
| Ollama | `100.67.120.6:11434` | Local LLM inference |
| Discord | Webhooks + Bot API | Event triggers, automated messages |
| Angel Cloud | REST API | Wellness check-ins, sentiment data |
| HaloFinance | REST API | Financial data, alerts |
| SRM Dispatch | REST/Webhooks | Dispatch events, scheduling |
| GitHub | Webhooks + API | Repo events, CI triggers |

## Repository Structure

```
N8N/
├── CLAUDE.md              # This file — source of truth
├── README.md              # Project overview
└── (building out)
```

### Planned
```
N8N/
├── docker-compose.yml     # n8n config (if we go Docker route on Pulsar)
├── .env.example           # Environment variable template (no secrets)
├── workflows/             # Exported n8n workflow JSON files
├── custom-nodes/          # Custom n8n nodes for ShaneBrain services
├── scripts/               # Setup, backup, maintenance scripts
├── docs/                  # Integration guides
├── CLAUDE.md
└── README.md
```

## Git Conventions

- **Default branch**: `main`
- **Remote**: `origin` → `thebardchat/N8N`
- **Branch naming**: `feature/description`, `fix/description`, `claude/description`
- **Commit messages**: Conventional commits, imperative mood. Name the service affected.

## Coding Conventions

- **TypeScript** for custom nodes, **Python** where ShaneBrain services are involved
- **Environment variables** for all secrets and connection strings. Never hardcode
- **Workflows**: Export as JSON, commit to `workflows/`
- **No secrets in git** — ever. `.env` files are gitignored
- **Tailscale IPs only** — never MagicDNS, never local IPs for cross-machine calls

## For AI Assistants

### Rules
1. Read this file first
2. This connects to everything — understand the integration point before touching anything
3. No secrets in code
4. Tailscale IPs only for cross-machine communication
5. Pulsar stays lean — AI workloads stay on the Pi
6. Test locally before pushing
7. Workflow JSON files are source of truth — export and commit after changes

### Cross-Repo Context
Reference these when building integrations:
- `thebardchat/shanebrain-core` — service endpoints, data formats
- `thebardchat/shanebrain_mcp` — MCP tool definitions, Weaviate schema
- `thebardchat/angel-cloud` — Angel Cloud API
- `thebardchat/HaloFinance` — financial data schemas
- `thebardchat/MASTER-Scheduler-Dashboard-SRM` — dispatch structures

### The Constitution
The ShaneBrain ecosystem operates under a governing covenant (`thebardchat/constitution`). Faith, family, local AI, the left-behind user. Every tool built here serves that mission.
