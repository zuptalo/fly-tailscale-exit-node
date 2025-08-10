#!/bin/bash

# Script to extract Tailscale state from Fly.io app and save as GitHub secret
# Usage: ./extract-state.sh <app-name>

set -e

APP_NAME="${1:-$APP_NAME}"

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: APP_NAME not provided"
    echo "Usage: $0 <app-name>"
    echo "   or: APP_NAME=<app-name> $0"
    exit 1
fi

echo "🔍 Extracting Tailscale state from app: $APP_NAME"

# Check if app exists and is running
if ! flyctl status --app "$APP_NAME" &> /dev/null; then
    echo "❌ Error: App $APP_NAME not found or not accessible"
    exit 1
fi

# Extract the state file as base64
echo "📄 Extracting tailscaled.state file..."
STATE_BASE64=$(flyctl ssh console --app "$APP_NAME" -C "base64 -w 0 /var/lib/tailscale/tailscaled.state" 2>/dev/null)

if [ -z "$STATE_BASE64" ]; then
    echo "❌ Error: Could not extract state file. The file might not exist yet."
    echo "💡 Make sure the Tailscale node has connected at least once to generate the state file."
    exit 1
fi

echo "✅ State file extracted successfully"
echo "📏 Base64 length: ${#STATE_BASE64} characters"

# Save to file for manual use
echo "$STATE_BASE64" > "tailscaled-state-${APP_NAME}.base64"
echo "💾 State saved to: tailscaled-state-${APP_NAME}.base64"

echo ""
echo "🔐 To set this as a GitHub secret, run:"
echo "gh secret set TS_STATE_FILE_BASE64 --body-file tailscaled-state-${APP_NAME}.base64"
echo ""
echo "Or manually add the following to your GitHub repository secrets:"
echo "Secret name: TS_STATE_FILE_BASE64"
echo "Secret value: (contents of tailscaled-state-${APP_NAME}.base64)"

# Optionally set the secret automatically if gh CLI is available
if command -v gh &> /dev/null; then
    echo ""
    read -p "🤖 Do you want to automatically set the GitHub secret? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if gh secret set TS_STATE_FILE_BASE64 --body-file "tailscaled-state-${APP_NAME}.base64"; then
            echo "✅ GitHub secret TS_STATE_FILE_BASE64 set successfully!"
        else
            echo "❌ Failed to set GitHub secret. Please set it manually."
        fi
    fi
else
    echo "💡 Install GitHub CLI (gh) to automatically set the secret next time."
fi

echo ""
echo "🎯 Next deployment will restore this state automatically!"