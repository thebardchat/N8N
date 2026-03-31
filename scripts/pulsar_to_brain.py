#!/usr/bin/env python3
"""Convert Pulsar Sentinel events into ShaneBrain MCP commands."""
import requests, os

N8N_URL = os.environ.get("N8N_WEBHOOK_URL", "http://100.81.70.117:5678/webhook/brain-order")
BRAIN_SECRET = os.environ.get("BRAIN_SECRET", "brain-secret-2026")

def ingest_pulsar_event(event):
    severity = event.get("severity", "low")
    if severity == "high":
        payload = {"action":"create_alert","priority":"high","message":event.get("details","Unknown"),"target":"admin","source":event.get("source","pulsar_sentinel")}
    else:
        payload = {"action":"log_event","event":event.get("event",""),"source":event.get("source",""),"details":event.get("details",""),"severity":severity}
    headers = {"Content-Type": "application/json", "auth": BRAIN_SECRET}
    return requests.post(N8N_URL, json=payload, headers=headers, timeout=30)
