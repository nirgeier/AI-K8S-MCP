# Stage 1: Build Node.js application
FROM node:20-alpine AS node-builder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src/ ./src/
COPY tsconfig.json ./

# Build TypeScript
RUN npm run build

# =============================================================================
# Stage 2: Multi-tool runtime environment
# =============================================================================
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# =============================================================================
# Install base utilities
# =============================================================================
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        curl \
        wget \
        git \
        vim \
        nano \
        openssh-server \
        openssh-client \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        apt-transport-https \
        jq \
        tree \
        netcat \
        iputils-ping \
        dnsutils \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install Node.js 20
# =============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest

# =============================================================================
# Install Python 3
# =============================================================================
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --no-cache-dir --upgrade pip setuptools wheel

# =============================================================================
# Install kubectl
# =============================================================================
RUN ARCH=$(dpkg --print-architecture) && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    kubectl version --client

# =============================================================================
# Install Helm 3
# =============================================================================
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    helm version

# =============================================================================
# Install Docker CLI (for Docker-in-Docker scenarios)
# =============================================================================
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install MCP dependencies
# =============================================================================
RUN pip3 install --no-cache-dir \
    fastmcp \
    requests \
    pyyaml \
    kubernetes

# Install TypeScript and MCP SDK globally
RUN npm install -g \
    typescript \
    ts-node \
    @modelcontextprotocol/sdk

# =============================================================================
# Setup SSH
# =============================================================================
RUN mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Configure SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# =============================================================================
# Create workspace directories
# =============================================================================
RUN mkdir -p /app && \
    mkdir -p /labs-scripts && \
    mkdir -p /root/.kube

# =============================================================================
# Copy built Node.js application from Stage 1
# =============================================================================
COPY --from=node-builder /app/build /app/build
COPY --from=node-builder /app/node_modules /app/node_modules
COPY --from=node-builder /app/package*.json /app/
COPY --from=node-builder /app/tsconfig.json /app/
COPY --from=node-builder /app/src /app/src

# =============================================================================
# Copy entrypoint script
# =============================================================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# =============================================================================
# Set working directory
# =============================================================================
WORKDIR /labs-scripts

# =============================================================================
# Expose ports
# =============================================================================
EXPOSE 22 3000 5000 8080

# =============================================================================
# Set entrypoint
# =============================================================================
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
