<div align="center">

# N8N — ShaneBrain Workflow Automation Hub

**The central orchestration layer for the ShaneBrain ecosystem.**

[![Constitution](https://img.shields.io/badge/Constitution-ShaneTheBrain-blue)](https://github.com/thebardchat/constitution)
[![Cluster](https://img.shields.io/badge/Cluster-4%20Nodes-brightgreen)](https://github.com/thebardchat/N8N)
[![MCP Tools](https://img.shields.io/badge/MCP%20Tools-42-purple)](https://github.com/thebardchat/shanebrain_mcp)
[![Sponsor](https://img.shields.io/badge/Sponsor-thebardchat-ea4aaa?logo=github-sponsors)](https://github.com/sponsors/thebardchat)

*Running on pulsar00100 — the fastest node in the 4-node Ollama cluster.*

</div>

---

## What This Does

n8n connects every service in the ShaneBrain network: the 42-tool MCP server, Weaviate vector DB, 4-node Ollama cluster, Discord bots, Angel Cloud, Mega Dashboard, HaloFinance, SRM dispatch operations, Facebook automation, voice pipeline, and everything else.

## The Cluster

```
┌─────────────────────────────────────────────────────┐
│              4-NODE OLLAMA CLUSTER                    │
│                                                      │
│  Pulsar (fastest) ←── n8n runs HERE                  │
│  Pi 5 (controller) ←── all services, Weaviate, MCP  │
│  Bullfrog ←── worker node                            │
│  Jaxton ←── worker node                              │
│                                                      │
│  All headless. All auto-start. All auto-failover.    │
└─────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# On pulsar00100:
git clone https://github.com/thebardchat/N8N.git
cd N8N
cp .env.example .env
docker-compose up -d

# Access UI at http://100.81.70.117:5678
```

## Connected Services

| Service | Tools | Connection |
|---------|-------|-----------|
| **ShaneBrain MCP** | 42 tools | HTTP :8100 — knowledge, chat, vault, planning, security, weather, reminders, and more |
| **Weaviate** | 17 collections | REST :8080 — vector DB, 210+ knowledge objects |
| **Ollama Cluster** | 4 nodes | Proxy :11435 — auto-routes to fastest available node |
| **Mega Dashboard** | Live monitoring | HTTPS :8300 — weather, sobriety, services, cluster, Pico, GitHub stars |
| **Discord Bots** | 3 bots | Webhooks — shanebrain, arcade, alerter |
| **Angel Cloud** | Gateway | :4200 — auth, chat, leaderboard, Messenger webhook |
| **Social Bot** | Facebook | Auto-posting with AI-generated content + promo images |
| **Voice Pipeline** | Whisper | :8200 — record on phone, transcribe on Pi |
| **SRM Dispatch** | PWA | :5173 — 16 drivers, 19 plants, block plant priority |
| **HaloFinance** | Financial | AI-powered budgeting and forecasting |
| **Pulsar Sentinel** | Security | Post-quantum crypto framework |

## Planned Workflows

| Workflow | Trigger | Action |
|----------|---------|--------|
| Star Alert | GitHub star event | Discord DM + log to Weaviate |
| Daily Digest | 5 AM cron | Morning briefing + weather + sobriety |
| Book Promo | Scheduled | Facebook post with random promo image |
| Security Alert | Service health check | Discord DM when service goes down |
| Knowledge Ingest | New voice dump | Auto-transcribe + store in Weaviate |
| Dispatch Summary | End of day | Route summary + driver stats |
| Tuesday Night Live | Tuesday 7 PM | Activate Messenger storyteller mode |

## Built With

<table>
  <tr>
    <td align="center" width="150">
      <b>Claude by Anthropic</b><br/>
      <sub>AI partner and co-builder.</sub><br/><br/>
      <a href="https://claude.ai"><code>claude.ai</code></a>
    </td>
    <td align="center" width="150">
      <b>Raspberry Pi 5</b><br/>
      <sub>Local AI compute node.</sub><br/><br/>
      <a href="https://www.raspberrypi.com"><code>raspberrypi.com</code></a>
    </td>
    <td align="center" width="150">
      <b>Pironman 5-MAX</b><br/>
      <sub>NVMe RAID 1 chassis by Sunfounder.</sub><br/><br/>
      <a href="https://www.sunfounder.com"><code>sunfounder.com</code></a>
    </td>
    <td align="center" width="150">
      <b>Hugging Face</b><br/>
      <sub>AI models and image generation.</sub><br/><br/>
      <a href="https://huggingface.co"><code>huggingface.co</code></a>
    </td>
  </tr>
</table>

---

## Support This Work

- **[Sponsor on GitHub](https://github.com/sponsors/thebardchat)**
- **[Buy the book](https://www.amazon.com/Probably-Think-This-Book-About/dp/B0GT25R5FD)** — *You Probably Think This Book Is About You*

---

<div align="center">

*Part of the [ShaneBrain Ecosystem](https://github.com/thebardchat) · Built under the [Constitution](https://github.com/thebardchat/constitution)*

</div>
