# Shadow/Mirroring Deployment Strategy

Shadow deployment (also known as traffic mirroring or dark launching) copies production traffic to a new version without affecting the user experience. The new version processes the mirrored traffic but responses are discarded.

## How It Works

1. **Production**: Users interact with the stable production version
2. **Shadow**: Copy of traffic is sent to the new version
3. **Processing**: Shadow version processes traffic but responses are discarded
4. **Monitoring**: Compare behavior and metrics between versions
5. **Decision**: Promote shadow to production if it behaves correctly

```
┌─────────────────────────────────────────────────────────────┐
│                        User Request                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Traffic Router/Proxy                      │
│                  (Ingress/Service Mesh)                      │
└─────────────────────────────────────────────────────────────┘
              │                               │
              │ Response                      │ Mirror (async)
              │ Returned                      │ Response Discarded
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │   Production    │             │     Shadow      │
    │   (v1.0.0)      │             │   (v2.0.0)      │
    │   Live traffic  │             │ Mirrored traffic│
    └─────────────────┘             └─────────────────┘
              │                               │
              └───────────┬───────────────────┘
                          ▼
              ┌─────────────────────┐
              │   Metrics/Logging   │
              │    (Compare both)   │
              └─────────────────────┘
```

## Directory Structure

```
shadow-mirroring/
├── manifests/           # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment-production.yaml
│   ├── deployment-shadow.yaml
│   ├── service.yaml
│   └── istio-mirroring.yaml
└── helm/               # Helm chart
    └── shadow-mirroring/
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Istio service mesh (for true traffic mirroring)
- Helm 3.x (for Helm deployment)

## Implementation Methods

### Method 1: Istio Traffic Mirroring (Recommended)

Uses Istio VirtualService for true traffic mirroring:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
spec:
  http:
  - route:
    - destination:
        host: production
    mirror:
      host: shadow
    mirrorPercentage:
      value: 100.0
```

### Method 2: Application-Level Mirroring

Implement mirroring in your application or API gateway.

### Method 3: NGINX Ingress Mirroring

Use NGINX mirror directive (requires custom configuration).

## Deployment Steps

### Using Raw Manifests (with Istio)

1. **Ensure Istio is installed:**
   ```bash
   istioctl version
   ```

2. **Create namespace with Istio injection:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl label namespace shadow-demo istio-injection=enabled
   ```

3. **Deploy production version:**
   ```bash
   kubectl apply -f manifests/deployment-production.yaml
   kubectl apply -f manifests/service.yaml
   ```

4. **Deploy shadow version:**
   ```bash
   kubectl apply -f manifests/deployment-shadow.yaml
   ```

5. **Apply Istio traffic mirroring:**
   ```bash
   kubectl apply -f manifests/istio-mirroring.yaml
   ```

6. **Monitor shadow version:**
   ```bash
   # Check shadow pod logs
   kubectl logs -n shadow-demo -l version=shadow -f
   
   # Compare metrics
   kubectl top pods -n shadow-demo
   ```

7. **Promote shadow to production:**
   ```bash
   # Update VirtualService to route to shadow
   kubectl patch virtualservice app-vs -n shadow-demo \
     --type='json' -p='[{"op":"replace","path":"/spec/http/0/route/0/destination/subset","value":"shadow"}]'
   ```

### Using Helm

1. **Install with production only:**
   ```bash
   helm install shadow-demo ./helm/shadow-mirroring -n shadow-demo --create-namespace
   ```

2. **Enable shadow deployment:**
   ```bash
   helm upgrade shadow-demo ./helm/shadow-mirroring -n shadow-demo \
     --set shadow.enabled=true
   ```

3. **Enable mirroring:**
   ```bash
   helm upgrade shadow-demo ./helm/shadow-mirroring -n shadow-demo \
     --set shadow.enabled=true \
     --set mirroring.enabled=true \
     --set mirroring.percentage=100
   ```

4. **Promote shadow:**
   ```bash
   helm upgrade shadow-demo ./helm/shadow-mirroring -n shadow-demo \
     --set production.enabled=false \
     --set shadow.enabled=true \
     --set mirroring.enabled=false
   ```

## Testing Without Istio

For testing without Istio, you can simulate mirroring by:

1. **Deploy both versions:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment-production.yaml
   kubectl apply -f manifests/deployment-shadow.yaml
   kubectl apply -f manifests/service.yaml
   ```

2. **Access production:**
   ```bash
   kubectl port-forward svc/app-service -n shadow-demo 8080:80
   curl localhost:8080
   ```

3. **Access shadow directly (for testing):**
   ```bash
   kubectl port-forward svc/app-shadow-service -n shadow-demo 8081:80
   curl localhost:8081
   ```

## Monitoring and Comparison

Key metrics to compare:

```bash
# Response times
kubectl logs -n shadow-demo -l version=production | grep "response_time"
kubectl logs -n shadow-demo -l version=shadow | grep "response_time"

# Error rates
kubectl logs -n shadow-demo -l version=shadow | grep -c "ERROR"

# Resource usage
kubectl top pods -n shadow-demo
```

## Cleanup

```bash
# Using manifests
kubectl delete namespace shadow-demo

# Using Helm
helm uninstall shadow-demo -n shadow-demo
kubectl delete namespace shadow-demo
```

## Advantages

- Zero risk to production traffic
- Real production traffic testing
- Compare behavior with actual data
- Catch errors before affecting users
- Test with production load

## Disadvantages

- Requires service mesh for true mirroring
- Double resource usage
- Complex debugging
- Not suitable for state-changing operations
- Responses from shadow are discarded
