#!/bin/bash

set -e

echo "[1/9] Updating system packages..."
apt update -y && apt upgrade -y

echo "[2/9] Installing required packages..."
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

echo "[3/9] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[4/9] Loading kernel modules..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "[5/9] Configuring sysctl..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

echo "[6/9] Installing containerd..."
apt install -y containerd

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Use systemd as the cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "[7/9] Adding Kubernetes apt repo..."

# Remove existing repo if present
rm -f /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt update -y

echo "[8/9] Installing Kubernetes 1.30.4..."
apt install -y kubelet=1.30.4-1.1 kubeadm=1.30.4-1.1 kubectl=1.30.4-1.1

# Prevent auto-upgrade
apt-mark hold kubelet kubeadm kubectl

echo "[9/9] Done! Kubernetes 1.30.4 installed."
kubeadm version
kubectl version --client