#!/bin/bash
echo "=== N8N Deployment on Pulsar00100 ==="
echo "1. scp -r . hubby@100.81.70.117:~/N8N/"
echo "2. ssh hubby@100.81.70.117"
echo "3. cd N8N/docker && docker-compose up -d"
echo "4. http://100.81.70.117:5678"
