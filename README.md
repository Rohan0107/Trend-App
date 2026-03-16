# Trend App - Full DevOps Project

## 🚀 Project Overview
This project demonstrates a complete DevOps pipeline for deploying the **Trendify** e-commerce application using Docker, Kubernetes, Jenkins CI/CD, Terraform, and Monitoring with Prometheus + Grafana on AWS.

## 🔗 Links
- **GitHub Repository:** https://github.com/Rohan0107/Trend-App
- **DockerHub Image:** https://hub.docker.com/r/rohan15543/trend-app
- **Application URL:** http://ace23ce15dbec404a94a428eeb233fe0-1064209352.ap-south-1.elb.amazonaws.com
- **Grafana Dashboard:** http://a4127af7873d84e32bc9e48e99f5daa3-199737531.ap-south-1.elb.amazonaws.com

## 📦 Application LoadBalancer ARN
- **App LoadBalancer:** `arn:aws:elasticloadbalancing:ap-south-1:837133225005:loadbalancer/ace23ce15dbec404a94a428eeb233fe0`
- **Grafana LoadBalancer:** `arn:aws:elasticloadbalancing:ap-south-1:837133225005:loadbalancer/a4127af7873d84e32bc9e48e99f5daa3`

---

## 🏗️ Architecture

```
GitHub → Jenkins → Docker Build → DockerHub → Kubernetes (EKS)
                                                      ↓
                                              Prometheus + Grafana
```

---

## 📁 Project Structure

```
Trend-App/
├── dist/                    # Built application files
├── k8s/
│   ├── deployment.yaml      # Kubernetes deployment
│   └── service.yaml         # Kubernetes service (LoadBalancer)
├── terraform/
│   └── main.tf              # AWS infrastructure (VPC, EC2, IAM)
├── Dockerfile               # Docker image definition
├── nginx.conf               # Nginx configuration
├── Jenkinsfile              # CI/CD pipeline script
├── .gitignore
└── .dockerignore
```

---

## 🐳 Phase 1: Docker

### Setup Instructions
1. Clone the repository:
```bash
git clone https://github.com/Rohan0107/Trend-App.git
cd Trend-App
```

2. Build the Docker image:
```bash
docker build -t trend-app .
```

3. Run the container:
```bash
docker run -p 3000:3000 trend-app
```

4. Open browser at `http://localhost:3000`

### Dockerfile Explanation
- Uses **nginx:alpine** as base image
- Copies built app from `dist/` folder to nginx html directory
- Custom `nginx.conf` to serve app on port 3000

---

## 🐙 Phase 2: DockerHub

- Image pushed to: `rohan15543/trend-app:latest`
- Jenkins automatically pushes new image on every commit

---

## 📂 Phase 3: Version Control

- Full codebase pushed to GitHub
- `.gitignore` excludes `node_modules`, `.env`, terraform state files, `.pem` keys
- `.dockerignore` excludes unnecessary files from Docker build

---

## ☁️ Phase 4: Terraform

### Infrastructure Created
- **VPC** with CIDR `10.0.0.0/16`
- **Subnet** in `ap-south-1a`
- **Internet Gateway** and **Route Table**
- **Security Group** (ports 22, 8080, 3000)
- **IAM Role** for EC2
- **EC2 Instance** (t3.micro) with Jenkins auto-installed

### Commands
```bash
cd terraform
terraform init
terraform plan
terraform apply
terraform destroy  # To clean up
```

---

## ⚙️ Phase 5: Jenkins CI/CD Pipeline

### Pipeline Stages
1. **Clone Repository** - Pulls latest code from GitHub
2. **Build Docker Image** - Builds image using Dockerfile
3. **Push to DockerHub** - Pushes image to `rohan15543/trend-app`
4. **Deploy to Kubernetes** - Applies k8s manifests to EKS cluster

### Setup Instructions
1. Access Jenkins at `http://<EC2-IP>:8080`
2. Install plugins: Docker, Git, Kubernetes, Pipeline
3. Add credentials:
   - `github-credentials` (GitHub username + token)
   - `dockerhub-credentials` (DockerHub username + access token)
4. Create pipeline project pointing to GitHub repo
5. Add GitHub webhook for auto-trigger

### GitHub Webhook
- URL: `http://<EC2-IP>:8080/github-webhook/`
- Trigger: Push events
- Auto-builds on every commit ✅

---

## ☸️ Phase 6: Kubernetes (AWS EKS)

### Cluster Setup
```bash
eksctl create cluster \
  --name trend-cluster \
  --region ap-south-1 \
  --nodegroup-name trend-nodes \
  --node-type t3.small \
  --nodes 2 \
  --managed
```

### Deployment
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Verify
```bash
kubectl get pods      # Should show 2 Running pods
kubectl get svc       # Should show LoadBalancer with external IP
kubectl get nodes     # Should show 2 Ready nodes
```

### deployment.yaml
- **Replicas:** 2
- **Image:** `rohan15543/trend-app:latest`
- **Port:** 3000

### service.yaml
- **Type:** LoadBalancer
- **Port:** 80 → 3000

---

## 📊 Phase 7: Monitoring (Prometheus + Grafana)

### Setup with Helm
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
```

### Access Grafana
```bash
# Get password
kubectl --namespace monitoring get secrets monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d

# Expose via LoadBalancer
kubectl --namespace monitoring patch svc monitoring-grafana \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

### Dashboards Available
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Node
- Kubernetes / API Server
- Kubernetes / Networking

---

## 🔧 Tech Stack

| Tool | Purpose |
|------|---------|
| Docker | Containerization |
| DockerHub | Image Registry |
| GitHub | Version Control |
| Terraform | Infrastructure as Code |
| Jenkins | CI/CD Pipeline |
| AWS EKS | Kubernetes Cluster |
| Prometheus | Metrics Collection |
| Grafana | Monitoring Dashboard |
| Nginx | Web Server |
| AWS EC2 | Jenkins Server |
| AWS VPC | Network Infrastructure |

---

## 👨‍💻 Author
**Rohan Lavande**
- GitHub: https://github.com/Rohan0107
