# Canary Deployment Strategy

Canary deployment is a technique to reduce the risk of introducing a new software version in production by slowly rolling out the change to a small subset of users before rolling it out to the entire infrastructure.

## How It Works

1. **Stable Version**: The current production version handles most traffic (e.g., 90%)
2. **Canary Version**: New version deployed with minimal replicas receiving small traffic (e.g., 10%)
3. **Gradual Rollout**: If canary performs well, gradually increase its traffic
4. **Full Rollout**: Eventually shift all traffic to the new version
5. **Rollback**: If issues detected, remove canary and keep stable

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                         │
│                         (Ingress)                            │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          │  90% Traffic      │    10% Traffic    │
          ▼                   │                   ▼
┌─────────────────┐           │         ┌─────────────────┐
│ Stable Service  │           │         │ Canary Service  │
└─────────────────┘           │         └─────────────────┘
          │                   │                   │
          ▼                   │                   ▼
┌─────────────────┐           │         ┌─────────────────┐
│Stable Deployment│           │         │Canary Deployment│
│   (v1.0.0)      │           │         │   (v2.0.0)      │
│   9 replicas    │           │         │   1 replica     │
└─────────────────┘           │         └─────────────────┘
```

## Directory Structure

```
canary/
├── manifests/           # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment-stable.yaml
│   ├── deployment-canary.yaml
│   ├── service.yaml
│   └── ingress-weighted.yaml
└── helm/               # Helm chart
    └── canary/
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Helm 3.x (for Helm deployment)
- NGINX Ingress Controller (for weighted routing)

## Implementation Methods

### Method 1: Replica-Based Canary (Simple)

Uses the ratio of replicas between stable and canary deployments to distribute traffic.

```bash
# 90% stable, 10% canary
kubectl apply -f manifests/deployment-stable.yaml   # 9 replicas
kubectl apply -f manifests/deployment-canary.yaml   # 1 replica
```

### Method 2: Ingress-Based Weighted Routing (NGINX Ingress)

Uses NGINX Ingress Controller annotations for weighted traffic splitting.

```bash
kubectl apply -f manifests/ingress-weighted.yaml
```

### Method 3: Service Mesh (Istio/Linkerd)

For production-grade canary deployments, consider using a service mesh for fine-grained traffic control.

## Deployment Steps

### Using Raw Manifests

1. **Create namespace and stable deployment:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment-stable.yaml
   kubectl apply -f manifests/service.yaml
   ```

2. **Deploy canary version:**
   ```bash
   kubectl apply -f manifests/deployment-canary.yaml
   ```

3. **Monitor canary performance:**
   ```bash
   # Watch pods
   kubectl get pods -n canary-demo -w
   
   # Check logs
   kubectl logs -n canary-demo -l version=canary
   ```

4. **Gradually increase canary (adjust replicas):**
   ```bash
   # Increase canary replicas
   kubectl scale deployment app-canary -n canary-demo --replicas=3
   
   # Decrease stable replicas
   kubectl scale deployment app-stable -n canary-demo --replicas=7
   ```

5. **Full rollout (if successful):**
   ```bash
   kubectl scale deployment app-canary -n canary-demo --replicas=10
   kubectl delete deployment app-stable -n canary-demo
   ```

6. **Rollback (if issues):**
   ```bash
   kubectl delete deployment app-canary -n canary-demo
   kubectl scale deployment app-stable -n canary-demo --replicas=10
   ```

### Using Helm

1. **Install with stable version:**
   ```bash
   helm install canary ./helm/canary -n canary-demo --create-namespace
   ```

2. **Enable canary:**
   ```bash
   helm upgrade canary ./helm/canary -n canary-demo --set canary.enabled=true
   ```

3. **Increase canary weight:**
   ```bash
   helm upgrade canary ./helm/canary -n canary-demo \
     --set canary.enabled=true \
     --set canary.weight=30
   ```

4. **Full rollout:**
   ```bash
   helm upgrade canary ./helm/canary -n canary-demo \
     --set stable.enabled=false \
     --set canary.enabled=true \
     --set canary.weight=100 \
     --set canary.replicaCount=10
   ```

## Testing

```bash
# Port-forward to test
kubectl port-forward svc/app-service -n canary-demo 8080:80

# Curl multiple times to see traffic distribution
for i in {1..20}; do curl -s localhost:8080 | grep -o 'Version: [^<]*'; done
```

## Cleanup

```bash
# Using manifests
kubectl delete namespace canary-demo

# Using Helm
helm uninstall canary -n canary-demo
kubectl delete namespace canary-demo
```

## Advantages

- Reduces risk of deploying buggy code
- Real user feedback before full rollout
- Easy rollback
- Production testing with real traffic

## Disadvantages

- More complex than blue/green
- Requires monitoring setup
- Traffic splitting can be tricky without proper tooling
- Users may have inconsistent experience during rollout
