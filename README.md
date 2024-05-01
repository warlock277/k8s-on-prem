# Setting Up a Local DevOps Server and Kubernetes

### Goal
To demonstrate how to set up a local DevOps environment for in-house software deployment.

### Focus
- Proxmox for virtualization
- Kubernetes for container orchestration
- Bitbucket CI/CD for automated deployments

### Key Benefits
- Faster deployment cycles
- Streamlined infrastructure management
- Automated CI/CD pipeline
- Reduced AWS/GCP/cloud service costs

---

## History
Running 10-12 services/apps on AWS costs nearly $500-600 per month for just two projects and two environments (dev & stage). Scaling up to multiple projects and environments (production, dev, stage) would significantly increase costs.

---

## The Plan

### Setting Up the Server Using Proxmox
#### Overview:
- Install **Proxmox** to manage Virtual Machines (VMs) for development and production.
- Create reusable **Ubuntu & Kubernetes templates** for rapid environment provisioning.
- Configure **port forwarding** on the gateway router (**MikroTik**).

#### Why Proxmox?
Proxmox Virtual Environment (VE) is an open-source server management platform tailored for enterprise virtualization. It includes:
- **KVM Hypervisor**
- **Linux Containers (LXC)**
- **Software-defined storage & networking**

---

## Preparing the System for Kubernetes
### Kubernetes Ingress
#### What is NGINX Ingress?
NGINX Ingress Controller manages external access to services within a Kubernetes cluster. It provides:
- **Load balancing**
- **SSL termination**
- **Reverse proxy functionality**

#### Using Helm for NGINX Ingress
Helm simplifies installation with pre-configured templates:
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-ingress ingress-nginx/ingress-nginx
```

#### Using a Manifest for NGINX Ingress
Alternatively, you can manually define an Ingress controller with YAML manifests:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```
Apply the configuration:
```sh
kubectl apply -f manifests/ingress.yaml
```

---

## Deployment on Kubernetes
### Why Use a Local Development Server?
#### Cost Efficiency
- **No ongoing cloud costs** – Avoid recurring charges from AWS/GCP.
- **Upfront investment only** – Buy hardware once, no monthly billing.

#### Full Control Over the Environment
- **Customization** – Modify hardware/software as needed.
- **Data security & compliance** – Keep sensitive data fully on-premise.

#### Tailored Resource Allocation
- **Optimized resources** – Allocate CPU, RAM, and storage as required.
- **No limits on usage** – No restrictions on bandwidth or requests.

#### Privacy and Control
- **Data privacy** – Avoid sharing sensitive data with third parties.
- **Custom backup strategies** – Implement custom backups without cloud dependency.

#### Learning & Experimentation
- **Gain hands-on experience** – Manage infrastructure directly.
- **Test new technologies** – Experiment without cloud costs.

---

## Running the Demo
### Prerequisites
Ensure you have the following installed:
- Proxmox VE
- Kubernetes (Minikube, K3s, or full cluster)
- Helm
- Docker
- Kubectl

### Cloning the Repository
```sh
git clone https://github.com/warlock277/k8-on-prem.git
cd k8-on-prem
```

### Setting Up Kubernetes
```sh
./setup-k8s.sh
```

### Deploying Services
```sh
kubectl apply -f manifests/
```

### Verifying Deployment
```sh
kubectl get pods
kubectl get services
kubectl get ingress
```

### Accessing the Application
If using Minikube:
```sh
minikube service my-service --url
```

For an Ingress-based setup, add an entry in `/etc/hosts`:
```
127.0.0.1 example.local
```
Access it via `http://example.local`

---

## Repository Structure
```
k8-on-prem/
│── manifests/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│── docker/
│   ├── Dockerfile
│── setup-k8s.sh
│── bitbucket-pipelines.yml
│── README.md
```

---

## When Should You Choose a Local Dev Server?
- When you want to **reduce long-term costs**.
- When **security and data control** are critical.
- When you need **fast access** without internet dependency.
- When you want **full control** over your development infrastructure.

---

## Next Steps
- [ ] Automate Kubernetes setup with Terraform.
- [ ] Integrate Prometheus and Grafana for monitoring.
- [ ] Set up ArgoCD for GitOps-based deployments.
- [ ] Add more sample applications to deploy.
