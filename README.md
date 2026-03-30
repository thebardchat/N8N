# N8N — ShaneBrain Workflow Automation Hub

n8n on **Pulsar0100** — the central nervous system for the ShaneBrain cluster.

## The Pipeline

```
Phone → N8N webhook (Pulsar:5678) → MCP server (Pi:8008) → Ollama embed → Weaviate store (Pi:8080) → Response
```

Pulsar runs n8n. Pi does AI. One hop on Tailscale.

## Quick Start

```bash
# On Pulsar0100
npm install -g n8n
n8n start --port 5678

# Access UI
# http://100.81.70.117:5678
```

## The Cluster

| Node | Role | Tailscale IP |
|------|------|-------------|
| Pi 5 (shanebrain-core) | AI heavy lifter — Ollama, Weaviate, MCP, Discord | `100.67.120.6` |
| Pulsar0100 | n8n automation hub | `100.81.70.117` |
| Laptop | Dev/access | `100.94.122.125` |

## Connected Services

- **ShaneBrain MCP** — 27-tool MCP server (Weaviate RAG + Ollama) on Pi port 8008
- **Weaviate** — Vector DB on Pi port 8080
- **Ollama** — Local LLM inference on Pi (llama3.2, nomic-embed-text, shanebrain-3b)
- **Discord bots** — Webhook routing and event triggers
- **Angel Cloud** — Mental wellness platform
- **HaloFinance** — Financial guidance
- **SRM Dispatch** — Concrete dispatch operations

## Build Order

- [ ] Install n8n on Pulsar, confirm port 5678
- [ ] Verify n8n → Pi MCP (100.67.120.6:8008)
- [ ] Verify n8n → Weaviate (100.67.120.6:8080)
- [ ] Build skeleton webhook workflow
- [ ] Test end-to-end
- [ ] Layer use-case workflows

See [CLAUDE.md](./CLAUDE.md) for full architecture and AI assistant guide.

Part of the [ShaneBrain ecosystem](https://github.com/thebardchat). Built on a Pi. Built for the 800M.
