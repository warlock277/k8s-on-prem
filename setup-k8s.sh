#!/bin/bash
set -e

echo "Setting up Kubernetes cluster..."

# Install dependencies
sudo apt update
sudo apt install -y docker.io curl

# Install kubeadm, kubectl, kubelet
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Initialize Kubernetes (single-node cluster)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "Kubernetes setup complete!"
