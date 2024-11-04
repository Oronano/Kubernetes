#!/bin/bash

# Get the public URL from ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

# Set the webhook endpoint URL
WEBHOOK_URL="$NGROK_URL/github-webhook"

# GitHub webhook configuration (replace with your values)
GITHUB_REPO="Oronano/Kubernetes"
GITHUB_TOKEN="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"

# Configure the webhook via GitHub API
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$GITHUB_REPO/hooks \
-d '{
  "config": {
    "url": "'$WEBHOOK_URL'",
    "content_type": "json",
    "insecure_ssl": "0"
  },
  "events": [
    "push"
  ],
  "active": true
}'

echo "Webhook configured successfully."
