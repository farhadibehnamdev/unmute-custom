# Deploying Unmute on Vast.ai (Docker Compose)

This guide walks you through deploying the Unmute application on a GPU instance from Vast.ai using **Docker Compose** and your custom domain.

## Prerequisites

- [Vast.ai Account](https://vast.ai/) with credits.
- A domain name (you have `green4lifeever.dpdns.org`).
- [Hugging Face Account](https://huggingface.co/) with a **Read-Only Access Token** (for downloading models).
- SSH Client (Terminal, PuTTY, etc.).

## Step 1: Rent a GPU Instance

1.  Go to the [Vast.ai Console](https://console.vast.ai/create/).
2.  **Filters**:
    - **GPU**: 1x RTX 3090 or RTX 4090 (Recommended for 24GB VRAM). 
      - *Note*: You need at least 24GB VRAM for the models.
    - **Disk Space**: At least **60GB** (Models are large).
    - **Image**: Select `nvidia/cuda:12.2.0-devel-ubuntu22.04` (or similar Ubuntu 22.04+ with CUDA).
    - **Launch Type**: ensure "Run a startup script" is unchecked or standard.
    - **Connections**: **Direct Port Forwarding** or **Public IP** is REQUIRED for hosting a web server on port 80/443. 
      - *Tip*: Look for instances with high reliability and "Open Ports" if possible, or use the "SSH Proxy" but you will need to map ports manually. **Prefer instances with a Static Public IP if available for easier DNS setup.**

3.  **Rent** the instance.

## Step 2: Configure DNS

If you are using **Cloudflare** for DNS management:
1.  Log in to your Cloudflare dashboard.
2.  Select your domain.
3.  Go to **DNS** > **Records**.
4.  Add a new record:
    - **Type**: `A`
    - **Name**: `green4lifeever` (or `@` for root domain)
    - **IPv4 address**: The **Public IP Address** of your Vast.ai instance (e.g., `123.45.67.89`).
    - **Proxy status**: Start with **DNS only** (Gray cloud icon) to ensure Let's Encrypt can certify the domain first. You can switch to **Proxied** (Orange cloud) later if needed, but be aware of timeouts with long-running connections (like WebSocket). For this app, **DNS Only** is safer to avoid issues.
5.  Save the record.

If you are using another provider, look for **A Record** settings.

## Step 3: Connect via SSH

1.  Copy the key-based SSH command from Vast.ai (e.g., `ssh -p 12345 root@1.2.3.4`).
2.  Run it in your terminal to connect.

## Step 4: Deploy

Run the following commands on the Vast.ai instance:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/farhadibehnamdev/unmute-custom.git
    cd unmute-custom
    ```

    *Note: If `git` is not installed, run `apt update && apt install git -y` first.*

2.  **Run the Setup Script**:
    ```bash
    chmod +x setup_vast.sh
    ./setup_vast.sh
    ```

3.  **Follow the Prompts**:
    - Enter your domain: `green4lifeever.dpdns.org`
    - Enter your Hugging Face Token.
    - (Optional) Enter specific LLM model or NewsAPI key.

4.  **Wait for Build and Start**:
    - The script will build images locally and start them with Docker Compose. This might take 10-20 minutes depending on download speeds.

## Step 5: Verification and Management

1.  Wait a few minutes for the services to start and SSL certificates to generate.
2.  Visit `https://green4lifeever.dpdns.org` in your browser.
  
### Managing the App

To see running containers:
```bash
docker compose -f docker-compose.prod.yml ps
```

To see logs:
```bash
docker compose -f docker-compose.prod.yml logs -f
```

To restart services:
```bash
docker compose -f docker-compose.prod.yml restart
```

To stop everything:
```bash
docker compose -f docker-compose.prod.yml down
```
