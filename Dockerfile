FROM tailscale/tailscale:latest

# Install base64 utility if not present
RUN apk add --no-cache coreutils

# Create the state directory
RUN mkdir -p /var/lib/tailscale

# Create startup script that handles state restoration
COPY <<'EOF' /usr/local/bin/tailscale-startup.sh
#!/bin/sh
set -e

echo "🚀 Starting Tailscale Exit Node..."

# Create state directory if it doesn't exist
mkdir -p "${TS_STATE_DIR:-/var/lib/tailscale}"

# If we have a base64-encoded state file, restore it
if [ ! -z "$TS_STATE_FILE_BASE64" ]; then
    echo "📄 Restoring Tailscale state from secret..."
    echo "$TS_STATE_FILE_BASE64" | base64 -d > "${TS_STATE_DIR:-/var/lib/tailscale}/tailscaled.state"
    echo "✅ State file restored"
else
    echo "ℹ️ No existing state file found, will create new one"
fi

# Ensure proper permissions
chmod 600 "${TS_STATE_DIR:-/var/lib/tailscale}"/* 2>/dev/null || true

echo "🔗 Starting Tailscale daemon..."
exec /usr/local/bin/containerboot
EOF

# Make the script executable
RUN chmod +x /usr/local/bin/tailscale-startup.sh

# Use our custom startup script
ENTRYPOINT ["/usr/local/bin/tailscale-startup.sh"]