#!/bin/bash
set -e

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker if not installed
install_docker() {
    if ! command_exists docker; then
        echo "Docker not found, installing..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release

        # Add Docker’s official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Set up the stable repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo usermod -aG docker "$USER"
        echo "Docker installed."
    else
        echo "Docker already installed."
    fi
}

# Install Minikube and Kubernetes if not installed
install_kubernetes() {
    if ! command_exists kubectl; then
        echo "Kubernetes not found, installing Minikube and kubectl..."
        
        # Install kubectl
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubectl

        # Install Minikube
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        echo "Minikube and kubectl installed."
    else
        echo "Kubernetes already installed."
    fi
}

# Install cri-dockerd if not installed
install_cri_dockerd() {
    if ! command_exists cri-dockerd; then
        echo "cri-dockerd not found, installing..."

        VERSION="0.3.15"  # Update to latest stable version if needed
        mkdir -p /tmp/cri-dockerd
        cd /tmp/cri-dockerd
        git clone https://github.com/Mirantis/cri-dockerd.git
        cd cri-dockerd
        git checkout $VERSION
        mkdir bin
        go build -o bin/cri-dockerd
        sudo mv bin/cri-dockerd /usr/local/bin/
        # Install systemd service files for cri-dockerd
        
        sudo wget -P /etc/systemd/system https://raw.githubusercontent.com/Mirantis/cri-dockerd/refs/heads/master/packaging/systemd/cri-docker.service
        sudo wget -P /etc/systemd/system https://raw.githubusercontent.com/Mirantis/cri-dockerd/refs/heads/master/packaging/systemd/cri-docker.socket

        # Enable cri-docker services
        sudo systemctl daemon-reload
        sudo systemctl enable cri-docker.service
        sudo systemctl enable cri-docker.socket
        sudo systemctl start cri-docker.service
        sudo systemctl start cri-docker.socket

        rm -rf /tmp/cri-dockerd
        
        echo "cri-dockerd installed and service enabled."
    else
        echo "cri-dockerd already installed."
    fi
}

# Install container networking plugins if not installed
install_cni_plugins() {
    if ! command_exists bridge; then
        echo "Container networking plugins not found, installing..."

        CNI_PLUGIN_VERSION="v1.6.0"
        CNI_PLUGIN_TAR="cni-plugins-linux-amd64-$CNI_PLUGIN_VERSION.tgz" # change arch if not on amd64
        CNI_PLUGIN_INSTALL_DIR="/opt/cni/bin"

        curl -LO "https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/$CNI_PLUGIN_TAR"
        sudo mkdir -p "$CNI_PLUGIN_INSTALL_DIR"
        sudo tar -xf "$CNI_PLUGIN_TAR" -C "$CNI_PLUGIN_INSTALL_DIR"
        rm "$CNI_PLUGIN_TAR"

        # Create /etc/cni/net.d directory if it doesn't exist
        if [ ! -d "/etc/cni/net.d" ]; then
            sudo mkdir -p /etc/cni/net.d
        fi

        echo "Container networking plugins installed."
    else
        echo "Container networking plugins already installed."
    fi
}

# Install PostgreSQL if not installed
install_postgresql() {
    if ! command_exists psql; then
        echo "PostgreSQL not found, installing..."
        sudo apt install -y curl ca-certificates
        sudo install -d /usr/share/postgresql-common/pgdg
        sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
        sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        sudo apt update
        sudo apt -y install postgresql
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        echo "PostgreSQL installed."
    else
        echo "PostgreSQL already installed."
    fi
}

# Install Python if not installed
install_python() {
    if ! command_exists python3; then
        echo "Python3 not found, installing..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
        echo "Python3 installed."
    else
        echo "Python3 already installed."
    fi
}

# Install required Python packages
install_python_packages() {
    echo "Installing Python packages..."
    python3 -m venv .venv
    .venv/bin/pip install --upgrade pip
    .venv/bin/pip install -r requirements.txt
    echo "Python packages installed."
}

# Initialize Docker and Kubernetes resources
initialize_docker_k8s() {
    echo "Initializing Docker and Kubernetes resources..."

    # Check if conntrack is installed (required for Kubernetes)
    if ! command -v conntrack >/dev/null 2>&1; then
        echo "conntrack is not installed. Installing conntrack..."
        sudo apt-get update && sudo apt-get install -y conntrack
    else
        echo "conntrack is already installed."
    fi

    # Install cri-dockerd if needed
    install_cri_dockerd

    # Install container networking plugins if needed
    install_cni_plugins

    # Check if Minikube is already running
    if ! minikube status >/dev/null 2>&1; then
        # Start Minikube with the appropriate driver
        if [ "$(id -u)" = "0" ]; then
            echo "Running as root. Using --driver=none for Minikube."
            minikube start --driver=none
        else
            echo "Running Minikube with Docker driver."
            minikube start --driver=docker
        fi
    else
        echo "Minikube already running."
    fi

    # Deploy PostgreSQL in Kubernetes if not deployed
    if ! kubectl get deployments | grep -q "postgres"; then
        echo "Deploying PostgreSQL in Kubernetes..."
        kubectl apply -f k8s/postgres-deployment.yaml
    else
        echo "PostgreSQL already deployed in Kubernetes."
    fi
}


# Main script
main() {
    echo "Starting setup on host machine..."

    # Step 1: Install Docker, Kubernetes, cri-dockerd, PostgreSQL, and Python
    install_docker
    install_kubernetes
    install_cri_dockerd
    install_cni_plugins
    install_postgresql
    install_python
    
    # Step 2: Install required Python packages
    install_python_packages

    # Step 3: Initialize Docker and Kubernetes resources
    initialize_docker_k8s

    echo "Setup complete!"
}

main
