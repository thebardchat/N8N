# N8N — ShaneBrain Workflow Automation Hub

The central orchestration layer for the ShaneBrain ecosystem, running on **pulsar00100**.

## What This Does

n8n connects every service in the network: the custom MCP server, Weaviate vector DB, Ollama local LLM, Discord bots, Angel Cloud, HaloFinance, SRM dispatch operations, and everything else.

## Quick Start

```bash
# Copy env template and configure
cp .env.example .env

# Start n8n
docker-compose up -d

# Access UI at http://pulsar00100:5678
```

## Connected Services

- **ShaneBrain Core** — Discord bot, RAG, voice pipeline, social automation
- **ShaneBrain MCP** — 27-tool MCP server (Weaviate + Ollama)
- **Angel Cloud** — Mental wellness platform
- **HaloFinance** — Financial guidance
- **SRM Dispatch** — Concrete dispatch operations
- **Pulsar Sentinel** — Security framework
- **Discord** — Bot webhooks and event routing

## Part of the ShaneBrain Ecosystem

See [CLAUDE.md](./CLAUDE.md) for full architecture and development guide.

Built on a Raspberry Pi. Built for the 800M.
