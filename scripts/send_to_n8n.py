#!/usr/bin/env python3
"""Send structured commands from ShaneBrain to N8N."""
import requests, os, json

N8N_URL = os.environ.get("N8N_WEBHOOK_URL", "http://100.81.70.117:5678/webhook/brain-order")
BRAIN_SECRET = os.environ.get("BRAIN_SECRET", "brain-secret-2026")

def send_to_n8n(action, **kwargs):
    payload = {"action": action, **kwargs}
    headers = {"Content-Type": "application/json", "auth": BRAIN_SECRET}
    resp = requests.post(N8N_URL, json=payload, headers=headers, timeout=30)
    return resp.json()

def create_order(driver, loads, product, destination, notes=""):
    return send_to_n8n("create_order", driver=driver, loads=loads, product=product, destination=destination, notes=notes)

def create_alert(priority, message, target="admin"):
    return send_to_n8n("create_alert", priority=priority, message=message, target=target)

def log_event(event, source, details, severity="low"):
    return send_to_n8n("log_event", event=event, source=source, details=details, severity=severity)

if __name__ == "__main__":
    print(json.dumps({"test": "send_to_n8n ready", "url": N8N_URL}))
