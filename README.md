# Kubernetes Deployment Strategies Showcase

A comprehensive collection of Kubernetes deployment strategy examples with manifests, Helm charts, and documentation for production-ready deployments.

## 🎯 Overview

This repository demonstrates the major Kubernetes deployment strategies used in production environments. Each strategy includes:

- ✅ Complete Kubernetes manifests
- ✅ Helm charts for flexible deployments
- ✅ Detailed documentation
- ✅ Working sample applications
- ✅ Step-by-step deployment guides

## 📋 Deployment Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| [Blue/Green](./examples/blue-green/) | Two identical environments, instant traffic switching | Zero-downtime releases, instant rollback |
| [Canary](./examples/canary/) | Gradual rollout to subset of users | Risk mitigation, testing in production |
| [Rolling Update](./examples/rolling-update/) | Gradual replacement of old pods with new | Standard deployments, resource efficient |
| [A/B Testing](./examples/ab-testing/) | Route traffic based on rules (headers, cookies) | Feature testing, experimentation |
| [Shadow/Mirroring](./examples/shadow-mirroring/) | Mirror production traffic to new version | Safe testing with production traffic |

## 📁 Repository Structure

```
k8s_deployment_showcase/
├── README.md                          # This file
├── common/
│   └── sample-app/                    # Sample application for demos
│       ├── Dockerfile
│       ├── nginx.conf
│       ├── index.html
│       └── README.md
└── examples/
    ├── blue-green/                    # Blue/Green deployment
    │   ├── README.md
    │   ├── manifests/
    │   │   ├── namespace.yaml
    │   │   ├── deployment-blue.yaml
    │   │   ├── deployment-green.yaml
    │   │   └── service.yaml
    │   └── helm/
    │       └── blue-green/
    │
    ├── canary/                        # Canary deployment
    │   ├── README.md
    │   ├── manifests/
    │   │   ├── namespace.yaml
    │   │   ├── deployment-stable.yaml
    │   │   ├── deployment-canary.yaml
    │   │   ├── service.yaml
    │   │   └── ingress-weighted.yaml
    │   └── helm/
    │       └── canary/
    │
    ├── rolling-update/                # Rolling Update deployment
    │   ├── README.md
    │   ├── manifests/
    │   │   ├── namespace.yaml
    │   │   ├── deployment.yaml
    │   │   └── service.yaml
    │   └── helm/
    │       └── rolling-update/
    │
    ├── ab-testing/                    # A/B Testing deployment
    │   ├── README.md
    │   ├── manifests/
    │   │   ├── namespace.yaml
    │   │   ├── deployment-a.yaml
    │   │   ├── deployment-b.yaml
    │   │   ├── service.yaml
    │   │   └── ingress.yaml
    │   └── helm/
    │       └── ab-testing/
    │
    └── shadow-mirroring/              # Shadow/Mirroring deployment
        ├── README.md
        ├── manifests/
        │   ├── namespace.yaml
        │   ├── deployment-production.yaml
        │   ├── deployment-shadow.yaml
        │   ├── service.yaml
        │   └── istio-mirroring.yaml
        └── helm/
            └── shadow-mirroring/
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured to access your cluster
- Helm 3.x (optional, for Helm deployments)
- NGINX Ingress Controller (for canary/A/B testing with weighted routing)
- Istio (for shadow/mirroring deployments)

### Deploy Blue/Green Example

```bash
# Using kubectl
kubectl apply -f examples/blue-green/manifests/namespace.yaml
kubectl apply -f examples/blue-green/manifests/deployment-blue.yaml
kubectl apply -f examples/blue-green/manifests/service.yaml

# Using Helm
helm install blue-green examples/blue-green/helm/blue-green \
  -n blue-green-demo --create-namespace
```

### Deploy Canary Example

```bash
# Using kubectl
kubectl apply -f examples/canary/manifests/namespace.yaml
kubectl apply -f examples/canary/manifests/deployment-stable.yaml
kubectl apply -f examples/canary/manifests/deployment-canary.yaml
kubectl apply -f examples/canary/manifests/service.yaml

# Using Helm
helm install canary examples/canary/helm/canary \
  -n canary-demo --create-namespace \
  --set canary.enabled=true
```

### Deploy Rolling Update Example

```bash
# Using kubectl
kubectl apply -f examples/rolling-update/manifests/

# Using Helm
helm install rolling-update examples/rolling-update/helm/rolling-update \
  -n rolling-update-demo --create-namespace
```

### Deploy A/B Testing Example

```bash
# Using kubectl
kubectl apply -f examples/ab-testing/manifests/

# Using Helm
helm install ab-testing examples/ab-testing/helm/ab-testing \
  -n ab-testing-demo --create-namespace
```

### Deploy Shadow/Mirroring Example

```bash
# Using kubectl (requires Istio)
kubectl apply -f examples/shadow-mirroring/manifests/

# Using Helm
helm install shadow examples/shadow-mirroring/helm/shadow-mirroring \
  -n shadow-demo --create-namespace \
  --set shadow.enabled=true \
  --set istio.enabled=true \
  --set mirroring.enabled=true
```

## 📊 Strategy Comparison

| Feature | Blue/Green | Canary | Rolling | A/B Testing | Shadow |
|---------|:----------:|:------:|:-------:|:-----------:|:------:|
| Zero Downtime | ✅ | ✅ | ✅ | ✅ | ✅ |
| Instant Rollback | ✅ | ⚠️ | ⚠️ | ✅ | N/A |
| Resource Efficient | ❌ | ✅ | ✅ | ⚠️ | ❌ |
| Production Testing | ❌ | ✅ | ❌ | ✅ | ✅ |
| User Segmentation | ❌ | ⚠️ | ❌ | ✅ | ❌ |
| Risk Level | Low | Low | Medium | Low | Very Low |
| Complexity | Low | Medium | Low | Medium | High |

**Legend:** ✅ Yes | ❌ No | ⚠️ Partial/Depends

## 🔧 Testing Deployments

### Port Forwarding

```bash
# Blue/Green
kubectl port-forward svc/app-service -n blue-green-demo 8080:80

# Canary
kubectl port-forward svc/app-service -n canary-demo 8080:80

# Rolling Update
kubectl port-forward svc/app-service -n rolling-update-demo 8080:80

# A/B Testing
kubectl port-forward svc/app-service -n ab-testing-demo 8080:80

# Shadow
kubectl port-forward svc/app-service -n shadow-demo 8080:80
```

Then visit http://localhost:8080 in your browser.

### Verify Deployments

```bash
# Check pods
kubectl get pods -n <namespace>

# Check services
kubectl get svc -n <namespace>

# Watch rollout status
kubectl rollout status deployment/<name> -n <namespace>
```

## 🧹 Cleanup

```bash
# Delete all demo namespaces
kubectl delete namespace blue-green-demo canary-demo rolling-update-demo ab-testing-demo shadow-demo

# Or using Helm
helm uninstall blue-green -n blue-green-demo
helm uninstall canary -n canary-demo
helm uninstall rolling-update -n rolling-update-demo
helm uninstall ab-testing -n ab-testing-demo
helm uninstall shadow -n shadow-demo
```

## 📚 Additional Resources

- [Kubernetes Deployments Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Helm Documentation](https://helm.sh/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Istio Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License