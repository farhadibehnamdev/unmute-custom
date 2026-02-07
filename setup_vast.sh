#!/bin/bash
set -e

echo "Starting Vast.ai setup (Docker Compose edition)..."

# 1. System Updates & Dependencies
echo "Installing dependencies..."
apt-get update
# Install essentials
apt-get install -y git curl wget build-essential python3-pip

# 2. Check/Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# 3. Check/Install NVIDIA Container Toolkit
if ! dpkg -l | grep -q nvidia-container-toolkit; then
    echo "Installing NVIDIA Container Toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update && apt-get install -y nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
fi

# 4. Install uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="/root/.cargo/bin:$PATH"
fi

# 5. Configure Docker for GPUs
echo "Configuring Docker for GPUs..."
python3 setup_gpu_swarm_node.py

# 6. Configuration Prompts
read -p "Enter your Domain (e.g., green4lifeever.dpdns.org): " DOMAIN
read -p "Enter your Hugging Face Token (Read Only): " HUGGING_FACE_HUB_TOKEN
# Optional: Model selection
read -p "Enter LLM Model (default: mistralai/Mistral-Small-24B-Instruct-2501): " KYUTAI_LLM_MODEL
KYUTAI_LLM_MODEL=${KYUTAI_LLM_MODEL:-mistralai/Mistral-Small-24B-Instruct-2501}
# Optional: News API
read -p "Enter NewsAPI Key (optional, press enter to skip): " NEWSAPI_API_KEY
if [ -z "$NEWSAPI_API_KEY" ]; then
    NEWSAPI_API_KEY=""
fi

export DOMAIN
export HUGGING_FACE_HUB_TOKEN
export KYUTAI_LLM_MODEL
export NEWSAPI_API_KEY

echo "Environment Variables Set:"
echo "DOMAIN: $DOMAIN"
echo "LLM: $KYUTAI_LLM_MODEL"

# 7. Build and Deploy
echo "Building and Starting containers with Docker Compose..."
# Use the production compose file
docker compose -f docker-compose.prod.yml up -d --build

echo "Deployment submitted! Check logs with: docker compose -f docker-compose.prod.yml logs -f"
