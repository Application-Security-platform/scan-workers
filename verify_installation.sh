#!/bin/bash

echo "Verifying system resources installation..."

# Verify Docker
if command -v docker >/dev/null 2>&1; then
    echo "Docker is installed:"
    docker --version
    sudo systemctl status docker --no-pager | grep "Active:" || echo "Docker service not running"
else
    echo "Docker is not installed."
fi

# Verify Minikube
if command -v minikube >/dev/null 2>&1; then
    echo "Minikube is installed:"
    minikube version
    echo "Minikube status:"
    minikube status
else
    echo "Minikube is not installed."
fi

# Verify kubectl
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl is installed:"
    kubectl version --client
else
    echo "kubectl is not installed."
fi

# Verify cri-dockerd
if command -v cri-dockerd >/dev/null 2>&1; then
    echo "cri-dockerd is installed."
    sudo systemctl status cri-docker.socket --no-pager | grep "Active:" || echo "cri-docker socket not running"
    sudo systemctl status cri-docker.service --no-pager | grep "Active:" || echo "cri-docker service not running"
else
    echo "cri-dockerd is not installed."
fi

# Verify CNI Plugins
if [ -d "/opt/cni/bin" ] && [ "$(ls -A /opt/cni/bin)" ]; then
    echo "CNI plugins are installed in /opt/cni/bin"
else
    echo "CNI plugins are not installed."
fi

if [ -d "/etc/cni/net.d" ] && [ "$(ls -A /etc/cni/net.d)" ]; then
    echo "/etc/cni/net.d directory exists and contains configuration files"
else
    echo "/etc/cni/net.d is missing or empty."
fi

# Verify PostgreSQL
if command -v psql >/dev/null 2>&1; then
    echo "PostgreSQL is installed:"
    psql --version
    sudo systemctl status postgresql --no-pager | grep "Active:" || echo "PostgreSQL service not running"
else
    echo "PostgreSQL is not installed."
fi


# Verify Go installation
if command -v go >/dev/null 2>&1; then
    echo "Go is installed."
    go version
else
    echo "Go is not installed."
fi




# Verify Python
if command -v python3 >/dev/null 2>&1; then
    echo "Python is installed:"
    python3 --version
    pip3 --version
else
    echo "Python3 is not installed."
fi

echo "Verification complete."
