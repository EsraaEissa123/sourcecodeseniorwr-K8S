# VProfile Application - Kubernetes Deployment

A multi-tier Java web application deployed on Kubernetes using Minikube. This project demonstrates containerization, orchestration, and deployment of a full-stack application with multiple backend services.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Technologies](#technologies)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment](#deployment)
- [Accessing the Application](#accessing-the-application)
- [Services](#services)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

## 🏗️ Architecture

The application follows a multi-tier architecture deployed on Kubernetes:

```
┌─────────────┐
│   Nginx     │  ← Load Balancer/Reverse Proxy
└──────┬──────┘
       │
┌──────▼──────┐
│   Tomcat    │  ← Java Application Server
│  (vproapp)  │
└──────┬──────┘
       │
   ┌───┴───┬────────┬─────────┐
   │       │        │         │
┌──▼──┐ ┌─▼───┐ ┌─▼─────┐ ┌─▼────┐
│MySQL│ │Memca│ │RabbitMQ│ │Secret│
└─────┘ │ched │ └────────┘ └──────┘
        └─────┘
```

## 🛠️ Technologies

- **Frontend**: Nginx (Reverse Proxy)
- **Backend**: Java Spring Boot, Tomcat 8
- **Database**: MySQL 5.7
- **Cache**: Memcached 1.6
- **Message Queue**: RabbitMQ 3
- **Container Orchestration**: Kubernetes (Minikube)
- **Containerization**: Docker
- **Build Tool**: Maven

## ✅ Prerequisites

- **Minikube** (v1.30+)
- **kubectl** (v1.26+)
- **Docker** (v20.10+)
- **Minimum Resources**: 4GB RAM, 2 CPUs

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd sourcecodeseniorwr-K8S
```

### 2. Start Minikube

```bash
minikube start --driver=docker
```

### 3. Deploy the Application

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Initialize Database

```bash
# Get the MySQL pod name
kubectl get pods -l app=vprodb

# Copy SQL file to pod
kubectl cp src/main/resources/db_backup.sql <vprodb-pod-name>:/tmp/db_backup.sql

# Import database schema
kubectl exec -it <vprodb-pod-name> -- mysql -uroot -pvprodbpass accounts < src/main/resources/db_backup.sql
```

### 5. Access the Application

```bash
# Set up port forwarding (requires sudo for port 80)
sudo -E kubectl port-forward service/vpronginx 80:80 --address 0.0.0.0
```

Then open your browser to: **http://localhost**

## 📦 Deployment

### Option 1: Automated Deployment (Recommended)

```bash
./deploy.sh
```

This script will:
1. Configure Docker to use Minikube's registry
2. Build the application Docker image
3. Build the Nginx Docker image
4. Deploy all Kubernetes resources

### Option 2: Manual Deployment

```bash
# Configure Docker environment
eval $(minikube docker-env)

# Build images
docker build -t vprofile-app:v1 .
docker build -t vprofile-nginx:v1 -f Dockerfile_nginx .

# Deploy to Kubernetes
kubectl apply -f k8s/
```

### Verify Deployment

```bash
# Check pod status
kubectl get pods

# Check services
kubectl get services

# Watch pod startup
kubectl get pods -w
```

All pods should be in `Running` state within 2-3 minutes.

## 🌐 Accessing the Application

### Port Forwarding to localhost:80

```bash
sudo -E kubectl port-forward service/vpronginx 80:80 --address 0.0.0.0
```

Access at: **http://localhost**

### Alternative: Port Forwarding to localhost:8081

```bash
kubectl port-forward service/vpronginx 8081:80 --address 0.0.0.0
```

Access at: **http://localhost:8081**

> **Note**: If using a non-standard port, you may need to manually adjust redirect URLs when navigating (e.g., `http://localhost:8081/login`).

### Default Credentials

- **Username**: `admin_vp`
- **Password**: `admin_vp`

## 🔧 Services

| Service | Type | Port | Description |
|---------|------|------|-------------|
| vpronginx | LoadBalancer | 80 | Nginx reverse proxy |
| vproapp | ClusterIP | 8080 | Tomcat application server |
| vprodb | ClusterIP | 3306 | MySQL database |
| vpromc | ClusterIP | 11211 | Memcached cache |
| vpromq | ClusterIP | 5672, 15672 | RabbitMQ message broker |

## 🐛 Troubleshooting

### Pods Not Starting

**Check pod status:**
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Common Issues:**
- Init containers stuck: Check connectivity to backend services
- Image pull errors: Ensure Minikube Docker environment is configured
- OOMKilled: Increase Minikube resources

### Application Errors

**403 Forbidden (CSRF Token Error)**
- **Cause**: Browser cookie conflict
- **Solution**: Use Incognito/Private browsing mode or clear cookies for localhost

**502 Bad Gateway**
- **Cause**: Backend pod not ready
- **Solution**: Wait for `vproapp` pod to reach Running state

**Database Connection Errors**
- **Cause**: Database not initialized
- **Solution**: Import `db_backup.sql` (see Quick Start step 4)

**Table doesn't exist**
- **Cause**: Database schema not loaded
- **Solution**: Execute the database initialization SQL script

### Port Forwarding Issues

**Port already in use:**
```bash
# Kill process using the port
sudo fuser -k 80/tcp

# Or use a different port
kubectl port-forward service/vpronginx 8081:80
```

### Checking Logs

```bash
# Application logs
kubectl logs -f <vproapp-pod-name>

# Nginx logs
kubectl logs -f <vpronginx-pod-name>

# Database logs
kubectl logs -f <vprodb-pod-name>
```

## 📁 Project Structure

```
sourcecodeseniorwr-K8S/
├── k8s/                          # Kubernetes manifests
│   ├── backend-dep.yaml          # Backend application deployment
│   ├── mysql-dep.yaml            # MySQL database deployment
│   ├── memcached-dep.yaml        # Memcached deployment
│   ├── rabbitmq-dep.yaml         # RabbitMQ deployment
│   ├── nginx-dep.yaml            # Nginx deployment
│   └── secret.yaml               # Kubernetes secrets
├── src/                          # Java application source
│   └── main/
│       ├── java/                 # Java source files
│       ├── resources/            # Application resources
│       │   ├── application.properties
│       │   └── db_backup.sql     # Database schema
│       └── webapp/               # Web resources (JSP, CSS, JS)
├── Dockerfile                    # Application container image
├── Dockerfile_nginx              # Nginx container image
├── nginx.conf                    # Nginx configuration
├── pom.xml                       # Maven build configuration
├── deploy.sh                     # Automated deployment script
└── README.md                     # This file
```

## 🔄 Rebuild and Redeploy

To rebuild and redeploy the application:

```bash
# Clean up existing deployment
kubectl delete -f k8s/

# Rebuild and deploy
./deploy.sh

# Re-initialize database
kubectl cp src/main/resources/db_backup.sql <vprodb-pod-name>:/tmp/
kubectl exec <vprodb-pod-name> -- mysql -uroot -pvprodbpass accounts < /tmp/db_backup.sql
```

## 📝 Notes

- The application uses init containers to ensure backend services are ready before starting
- All sensitive credentials are stored in Kubernetes secrets
- The Nginx proxy handles SSL termination and load balancing
- Minikube LoadBalancer services remain in `<pending>` state (expected behavior)

## 📄 License

This project is for educational purposes.

---

**Made with ❤️ for DevOps Learning**
