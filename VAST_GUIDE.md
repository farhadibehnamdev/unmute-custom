# Deploying Unmute on Vast.ai

This guide walks you through deploying the Unmute application on a GPU instance from Vast.ai using your custom domain.

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

1.  Once the instance is running, copy its **Public IP Address**.
2.  Go to your DNS provider (for `green4lifeever.dpdns.org`).
3.  Create/Update an **A Record** pointing to the Vast.ai Instance IP.

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

4.  **Wait for Build and Deploy**:
    - The script will install dependencies, build Docker images locally (this takes time!), and deploy the swarm.

## Step 5: Verification

1.  Wait a few minutes for the services to start and SSL certificates to generate.
2.  Visit `https://green4lifeever.dpdns.org` in your browser.
3.  Check status on the server:
    ```bash
    docker service ls
    docker service logs -f unmute_frontend
    ```
