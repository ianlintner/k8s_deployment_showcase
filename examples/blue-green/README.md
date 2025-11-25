# Blue/Green Deployment Strategy

Blue/Green deployment is a release strategy that reduces downtime and risk by running two identical production environments called Blue and Green.

## How It Works

1. **Blue Environment**: The current production environment serving all traffic
2. **Green Environment**: The new version deployed alongside blue
3. **Switch**: Once green is validated, traffic is switched from blue to green
4. **Rollback**: If issues occur, switch back to blue instantly

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                         │
│                    (Service/Ingress)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────┴───────────────┐
              │        Selector Switch        │
              │   (version: blue/green)       │
              └───────────────┬───────────────┘
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │  Blue Deployment │             │ Green Deployment │
    │   (v1.0.0)      │             │    (v2.0.0)      │
    │   3 replicas    │             │    3 replicas    │
    └─────────────────┘             └─────────────────┘
```

## Directory Structure

```
blue-green/
├── manifests/           # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment-blue.yaml
│   ├── deployment-green.yaml
│   └── service.yaml
└── helm/               # Helm chart
    └── blue-green/
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Helm 3.x (for Helm deployment)

## Deployment Steps

### Using Raw Manifests

1. **Create the namespace and blue deployment:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment-blue.yaml
   kubectl apply -f manifests/service.yaml
   ```

2. **Verify blue deployment is running:**
   ```bash
   kubectl get pods -n blue-green-demo -l version=blue
   ```

3. **Deploy green version (without receiving traffic):**
   ```bash
   kubectl apply -f manifests/deployment-green.yaml
   ```

4. **Verify green deployment is healthy:**
   ```bash
   kubectl get pods -n blue-green-demo -l version=green
   ```

5. **Switch traffic to green:**
   ```bash
   kubectl patch service app-service -n blue-green-demo -p '{"spec":{"selector":{"version":"green"}}}'
   ```

6. **Rollback to blue if needed:**
   ```bash
   kubectl patch service app-service -n blue-green-demo -p '{"spec":{"selector":{"version":"blue"}}}'
   ```

### Using Helm

1. **Install with blue active:**
   ```bash
   helm install blue-green ./helm/blue-green -n blue-green-demo --create-namespace
   ```

2. **Upgrade with green deployment:**
   ```bash
   helm upgrade blue-green ./helm/blue-green -n blue-green-demo --set green.enabled=true
   ```

3. **Switch to green:**
   ```bash
   helm upgrade blue-green ./helm/blue-green -n blue-green-demo --set activeColor=green
   ```

4. **Rollback:**
   ```bash
   helm upgrade blue-green ./helm/blue-green -n blue-green-demo --set activeColor=blue
   ```

## Testing

Port-forward to test locally:
```bash
kubectl port-forward svc/app-service -n blue-green-demo 8080:80
```

Then visit http://localhost:8080 to see which version is active.

## Cleanup

```bash
# Using manifests
kubectl delete namespace blue-green-demo

# Using Helm
helm uninstall blue-green -n blue-green-demo
kubectl delete namespace blue-green-demo
```

## Advantages

- Zero-downtime deployments
- Instant rollback capability
- Full testing of production environment before switch
- Simple traffic switching mechanism

## Disadvantages

- Requires double the resources during deployment
- Database migrations can be complex
- Long-running transactions may be interrupted during switch
