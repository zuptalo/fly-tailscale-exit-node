# Tailscale Exit Node on Fly.io

Deploy a Tailscale exit node on Fly.io with automated GitHub Actions.

## Prerequisites

- Fly.io account
- Headscale server with pre-auth key
- GitHub repo secrets configured

## Setup

### 1. Generate Fly.io Organization Token

**Important:** Use an Organization Token (not a Personal Access Token) for GitHub Actions.

1. Go to the Fly.io Dashboard: https://fly.io/dashboard/{your-username}/tokens
2. Click "Create Token"
3. Select "Organization Token"
4. Choose your organization (usually "personal" for individual accounts)
5. Set expiration as needed (or leave blank for no expiration)
6. Copy the generated token

### 2. Set Repository Secrets

Go to your repo → Settings → Secrets and variables → Actions, add:

- `FLY_API_TOKEN` - Organization token from step 1
- `HEADSCALE_URL` - Your Headscale server URL (e.g., `https://headscale.example.com`)
- `TS_AUTHKEY` - Pre-auth key from Headscale
- `APP_NAME` - Fly.io app name (e.g., `my-tailscale-exit-node`)

**Note:** Make sure your `APP_NAME` is unique. If you get authorization errors, try adding a suffix like `-v2` or your username.

### 3. Deploy/Destroy

- **Deploy**: Go to Actions → "Deploy Exit Node" → Run workflow → Select gateway region from dropdown
- **Destroy**: Go to Actions → "Destroy Exit Node" → Run workflow

**Important:** The deploy workflow will automatically destroy any existing app with the same name before deploying to the new region. This ensures a clean deployment in your selected region.

## Troubleshooting

### Authorization Errors
If you see "Not authorized to deploy this app":

1. **Check your token**: Make sure you're using an Organization Token (not Personal Access Token)
2. **Try a different app name**: Your `APP_NAME` might conflict with an existing app
3. **Verify your organization**: Run `flyctl orgs list` to see your available organizations

### App Name Conflicts
If your app name is taken, try:
- `your-username-tailscale-exit`
- `tailscale-exit-node-v2`
- `my-exit-node-$(date +%s)` (timestamped)

## Post-Deployment

1. Check your Headscale admin for the new node: `fly-exit-node`
2. Enable exit node if not auto-enabled
3. Use from Tailscale client: `tailscale up --exit-node=fly-exit-node`

## Useful Commands

```bash
  # List your apps
  fly apps list
```
```bash
  # View logs
  fly logs --app your-app-name
```
```bash
  # SSH to node
  fly ssh console --app your-app-name
```
```bash
  # Restart
  fly machines restart --app your-app-name
```
```bash
  # Check app status
  fly status --app your-app-name
```

## Gateway Regions Available

**This deployment only supports Fly.io Gateway regions** for enhanced connectivity, WireGuard access, and private networking capabilities.

Available gateway regions:
- `ams` - Amsterdam, Netherlands
- `bom` - Mumbai, India
- `cdg` - Paris, France
- `dfw` - Dallas, Texas (US)
- `fra` - Frankfurt, Germany ⭐ **(Recommended - Highest capacity)**
- `hkg` - Hong Kong, Hong Kong
- `iad` - Ashburn, Virginia (US)
- `lhr` - London, United Kingdom
- `nrt` - Tokyo, Japan
- `ord` - Chicago, Illinois (US)
- `qro` - Querétaro, Mexico
- `scl` - Santiago, Chile
- `sea` - Seattle, Washington (US)
- `sin` - Singapore, Singapore
- `sjc` - San Jose, California (US)
- `syd` - Sydney, Australia
- `yyz` - Toronto, Canada

### Why Gateway Regions Only?

Gateway regions provide:
- **WireGuard VPN access** - Enhanced connectivity to your Fly.io private network
- **SSH connectivity** - Direct console access for troubleshooting and state extraction
- **Private networking** - Better app-to-app communication if you expand your setup
- **Debugging capabilities** - Enhanced monitoring and management tools

### Recommended Regions by Geography:

**Europe:**
- `fra` - Frankfurt, Germany (highest capacity)
- `ams` - Amsterdam, Netherlands
- `lhr` - London, United Kingdom
- `cdg` - Paris, France

**North America:**
- `iad` - Ashburn, Virginia (US)
- `sjc` - San Jose, California (US)
- `dfw` - Dallas, Texas (US)
- `sea` - Seattle, Washington (US)

**Asia Pacific:**
- `nrt` - Tokyo, Japan
- `sin` - Singapore, Singapore
- `hkg` - Hong Kong, Hong Kong
- `syd` - Sydney, Australia

## License

MIT - Free to use for anyone