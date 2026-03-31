# Order Webhook

POST /webhook/brain-order

Headers: auth: brain-secret-2026

Body:
```json
{"action":"create_order","driver":"Roberto","loads":3,"product":"57 stone","destination":"Plant 513","notes":""}
```

Actions: create_order, create_alert, log_event, schedule_driver, update_loads, cancel_order, driver_status, plant_status, daily_summary
