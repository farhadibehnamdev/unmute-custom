#!/bin/bash
set -e

echo "Starting Vast.ai setup..."

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
# Ensure PyYAML/setup deps are installed for the python script if needed, 
# but setup_gpu_swarm_node.py only uses standard lib (json, subprocess, pathlib).
python3 setup_gpu_swarm_node.py

# 6. Initialize Swarm
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init --advertise-addr $(hostname -i)
fi

# 7. Configuration Prompts
read -p "Enter your Domain (e.g., green4lifeever.dpdns.org): " DOMAIN
read -p "Enter your Hugging Face Token (Read Only): " HUGGING_FACE_HUB_TOKEN
# Optional: Model selection
read -p "Enter LLM Model (default: mistralai/Mistral-Small-24B-Instruct-2501): " KYUTAI_LLM_MODEL
KYUTAI_LLM_MODEL=${KYUTAI_LLM_MODEL:-mistralai/Mistral-Small-24B-Instruct-2501}
# Optional: News API
read -p "Enter NewsAPI Key (optional, press enter to skip): " NEWSAPI_API_KEY

export DOMAIN
export HUGGING_FACE_HUB_TOKEN
export KYUTAI_LLM_MODEL
export NEWSAPI_API_KEY
# Set defaults for other env vars used in vast-deploy.yml if necessary
# We'll just export them.

echo "Environment Variables Set:"
echo "DOMAIN: $DOMAIN"
echo "LLM: $KYUTAI_LLM_MODEL"

# 8. Build Images
echo "Building Docker images... (This may take a while)"
# We use docker compose build because 'stack deploy' doesn't build
docker compose -f vast-deploy.yml build

# 9. Deploy
echo "Deploying to Swarm..."
docker stack deploy -c vast-deploy.yml unmute

echo "Deployment submitted! Check status with: docker service ls"
echo "If this is the first run, it might take some time for images to start and certificates to generate."
