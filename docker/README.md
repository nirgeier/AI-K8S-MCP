# K-Agent Development Docker Environment

This Docker environment provides a CentOS-compatible development environment with all the tools needed for K-Agent Labs development.

## Included Tools

Based on the required tools from the K-Agent Labs documentation:

- **Python 3** - For Python-based MCP servers and development
- **Node.js** - For JavaScript/TypeScript MCP servers and tools
- **Git** - Version control
- **kubectl** - Kubernetes command-line tool
- **MCP Inspector** - For testing MCP servers

## Excluded Tools

The following tools are not included in the Docker container as they don't make sense in a containerized environment:

- **Visual Studio Code** - GUI application
- **Docker** - Docker-in-Docker complexity
- **Ollama** - Requires special setup for containers

## Usage

### Build and Run

```bash
# Build the Docker image
docker-compose build

# Start the container
docker-compose up -d

# Enter the container
docker-compose exec kagent-dev bash
```

### Alternative: Direct Docker Commands

```bash
# Build the image
docker build -t kagent-dev .

# Run the container
docker run -it --rm \
  -v $(pwd)/../:/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8000:8000 \
  --name kagent-dev \
  kagent-dev
```

## Development Workflow

Once inside the container, you can:

1. **Navigate to the Labs directory:**
   ```bash
   cd Labs
   ```

2. **Install Python dependencies:**
   ```bash
   pip3 install -r requirements.txt
   ```

3. **Install Node.js dependencies:**
   ```bash
   npm install
   ```

4. **Run MkDocs development server:**
   ```bash
   mkdocs serve -a 0.0.0.0:8000
   ```

5. **Test kubectl connectivity:**
   ```bash
   kubectl version --client
   ```

6. **Use MCP Inspector:**
   ```bash
   mcp-inspector --help
   ```

## User Account

- **Username:** kagent
- **Password:** kagent
- **Home Directory:** /home/kagent

The container runs as a non-root user for better security.

## Volume Mounts

- `/workspace` - Mounted to the parent directory (K-Agent repository)
- `/var/run/docker.sock` - For Docker access from within the container (if needed)

## Ports

- `8000` - Exposed for MkDocs development server

## Portainer (Docker Management UI)

Portainer is included in the compose setup to provide a web-based Docker management interface.

### Access Portainer

- **Web UI:** http://localhost:9000
- **Secure UI:** https://localhost:9443

### First Time Setup

1. Open http://localhost:9000 in your browser
2. Create an admin password
3. Select "Docker" as the environment type
4. Choose "Local" connection

### Features

- Manage containers, images, networks, and volumes
- View logs and resource usage
- Execute commands in containers
- Deploy stacks with docker-compose

## Base Image

Uses Rocky Linux 9, which is CentOS-compatible and receives long-term support.
