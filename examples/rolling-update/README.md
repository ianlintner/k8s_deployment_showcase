# Rolling Update Deployment Strategy

Rolling Update is the default Kubernetes deployment strategy that gradually replaces instances of the previous version with the new version.

## How It Works

1. **Start**: All pods running version 1
2. **Update**: Kubernetes creates new pods with version 2
3. **Scale Down**: Old pods are gradually terminated
4. **Complete**: All pods running version 2

```
Time 0:  [v1] [v1] [v1] [v1]          ← All pods running v1
Time 1:  [v1] [v1] [v1] [v2]          ← One v2 pod created
Time 2:  [v1] [v1] [v2] [v2]          ← Two v2 pods
Time 3:  [v1] [v2] [v2] [v2]          ← Three v2 pods
Time 4:  [v2] [v2] [v2] [v2]          ← All pods running v2
```

## Directory Structure

```
rolling-update/
├── manifests/           # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── helm/               # Helm chart
    └── rolling-update/
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Helm 3.x (for Helm deployment)

## Key Configuration Parameters

### maxSurge
Maximum number of pods that can be created above the desired number during update.
- Can be absolute number (e.g., 1) or percentage (e.g., 25%)
- Default: 25%

### maxUnavailable
Maximum number of pods that can be unavailable during update.
- Can be absolute number (e.g., 1) or percentage (e.g., 25%)
- Default: 25%

### minReadySeconds
Minimum time a pod should be ready before considered available.

### progressDeadlineSeconds
Maximum time for deployment to make progress before considered failed.

## Deployment Steps

### Using Raw Manifests

1. **Create namespace and initial deployment:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment.yaml
   kubectl apply -f manifests/service.yaml
   ```

2. **Watch the rollout:**
   ```bash
   kubectl rollout status deployment/app -n rolling-update-demo -w
   ```

3. **Trigger an update (change image or config):**
   ```bash
   # Update the image version
   kubectl set image deployment/app -n rolling-update-demo app=nginx:1.26-alpine
   
   # Or update environment variable
   kubectl set env deployment/app -n rolling-update-demo APP_VERSION=2.0.0
   ```

4. **Watch rolling update progress:**
   ```bash
   kubectl get pods -n rolling-update-demo -w
   ```

5. **Rollback if needed:**
   ```bash
   # View rollout history
   kubectl rollout history deployment/app -n rolling-update-demo
   
   # Rollback to previous version
   kubectl rollout undo deployment/app -n rolling-update-demo
   
   # Rollback to specific revision
   kubectl rollout undo deployment/app -n rolling-update-demo --to-revision=2
   ```

6. **Pause and resume rollout:**
   ```bash
   # Pause
   kubectl rollout pause deployment/app -n rolling-update-demo
   
   # Resume
   kubectl rollout resume deployment/app -n rolling-update-demo
   ```

### Using Helm

1. **Install:**
   ```bash
   helm install rolling-update ./helm/rolling-update -n rolling-update-demo --create-namespace
   ```

2. **Upgrade to new version:**
   ```bash
   helm upgrade rolling-update ./helm/rolling-update -n rolling-update-demo --set app.version=2.0.0
   ```

3. **Custom rolling update parameters:**
   ```bash
   helm upgrade rolling-update ./helm/rolling-update -n rolling-update-demo \
     --set strategy.maxSurge=1 \
     --set strategy.maxUnavailable=0
   ```

## Strategy Configurations

### Zero Downtime (Conservative)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```
- Never reduces capacity below desired
- Requires extra resources
- Slowest but safest

### Fast Update
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 50%
    maxUnavailable: 50%
```
- Faster updates
- May reduce capacity temporarily
- Good for stateless applications

### Balanced (Default)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 25%
```
- Good balance of speed and availability
- Kubernetes default

## Testing

```bash
# Port-forward to test
kubectl port-forward svc/app-service -n rolling-update-demo 8080:80

# Watch pods during update
watch kubectl get pods -n rolling-update-demo -o wide
```

## Monitoring Rollout

```bash
# Check rollout status
kubectl rollout status deployment/app -n rolling-update-demo

# View deployment details
kubectl describe deployment/app -n rolling-update-demo

# View events
kubectl get events -n rolling-update-demo --sort-by='.lastTimestamp'
```

## Cleanup

```bash
# Using manifests
kubectl delete namespace rolling-update-demo

# Using Helm
helm uninstall rolling-update -n rolling-update-demo
kubectl delete namespace rolling-update-demo
```

## Advantages

- Built into Kubernetes (no additional tools needed)
- Zero downtime when configured correctly
- Automatic rollback on failure
- History of revisions maintained

## Disadvantages

- Cannot test new version before routing traffic
- Users may hit different versions during rollout
- Database schema changes require careful handling
- Slower than blue/green for large deployments
